#
# Author:: Joshua Timberman <joshua@chef.io>
# Author:: Patrick Wright <patrick@chef.io>
# Copyright (c) 2015-2017, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :chef_ingredient

default_action :install

property :product_name, kind_of: String, name_attribute: true
property :config, kind_of: String

# Determine what version to install from which channel
property :version, kind_of: [String, Symbol], default: :latest
property :channel, kind_of: Symbol, default: :stable, equal_to: [:stable, :current, :unstable]

# Install package from local file
property :package_source, kind_of: String

# Set the *-ctl command to use when doing reconfigure
property :ctl_command, kind_of: String

# Package resources used on rhel and debian platforms
property :options, kind_of: String
property :timeout, kind_of: [Integer, String, NilClass]

# Accept the license when applicable
property :accept_license, kind_of: [TrueClass, FalseClass], default: false

# Enable selecting packages built for earlier versions in
# platforms that are not yet officially added to Chef support matrix
property :platform_version_compatibility_mode, kind_of: [TrueClass, FalseClass]

# Configure specific platform package
property :platform, kind_of: String
property :platform_version, kind_of: String
property :architecture, kind_of: String

platform_family = node['platform_family']

action_class do
  require_relative '../libraries/helpers'
  include ChefIngredientCookbook::Helpers

  case platform_family
  when 'debian', 'rhel', 'suse', 'windows'
    require_relative '../libraries/default_handler'
    include ChefIngredient::DefaultHandler
  else
    # OmnitruckHandler is used for Solaris, AIX, FreeBSD, etc.
    # Eventually, we would like to support all platforms with the DefaultHandler
    require_relative '../libraries/omnitruck_handler'
    include ChefIngredient::OmnitruckHandler
  end
end

action :install do
  check_deprecated_properties
  add_config(new_resource.product_name, new_resource.config)
  declare_chef_run_stop_resource

  handle_install
end

action :upgrade do
  check_deprecated_properties
  add_config(new_resource.product_name, new_resource.config)
  declare_chef_run_stop_resource

  handle_upgrade
end

action :uninstall do
  check_deprecated_properties
  handle_uninstall
end

action :reconfigure do
  check_deprecated_properties
  add_config(new_resource.product_name, new_resource.config)

  if ingredient_ctl_command.nil?
    Chef::Log.warn "Product '#{new_resource.product_name}' does not support reconfigure."
    Chef::Log.warn 'chef_ingredient is skipping :reconfigure.'
  else
    # Render the config in case it is not rendered yet
    ingredient_config new_resource.product_name do
      action :render
      not_if { get_config(new_resource.product_name).empty? }
    end

    # If accept_license is set, drop .license.accepted file so that
    # reconfigure does not prompt for license acceptance. This is
    # the backwards compatible way of accepting a Chef license.
    if new_resource.accept_license && %w(analytics manage reporting compliance).include?(new_resource.product_name)
      # The way we construct the data directory for a product, that looks
      # like /var/opt/<product_name> is to get the config file path that
      # looks like /etc/<product_name>/<product_name>.rb and do path
      # manipulation.
      product_data_dir_name = ::File.basename(::File.dirname(ingredient_config_file(new_resource.product_name)))
      product_data_dir = ::File.join('/var/opt', product_data_dir_name)

      directory product_data_dir do
        recursive true
        action :create
      end

      file ::File.join(product_data_dir, '.license.accepted') do
        action :touch
      end
    end

    execute "#{ingredient_package_name}-reconfigure" do
      command "#{ingredient_ctl_command} reconfigure"
    end
  end
end
