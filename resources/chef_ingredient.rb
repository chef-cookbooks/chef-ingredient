#
# Author:: Joshua Timberman <joshua@chef.io>
# Author:: Patrick Wright <patrick@chef.io>
# Copyright:: 2015-2017, Chef Software, Inc. <legal@chef.io>
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

property :product_name, String, name_property: true
property :config, String

# Determine what version to install from which channel
property :version, [String, Symbol], default: :latest
property :channel, Symbol, default: :stable, equal_to: [:stable, :current, :unstable]

# Install package from local file
property :package_source, String

# Set the *-ctl command to use when doing reconfigure
property :ctl_command, String

# Package resources used on rhel and debian platforms
property :options, String

property :timeout, [Integer, String]

# Accept the license when applicable
property :accept_license, [true, false], default: false

# Enable selecting packages built for earlier versions in
# platforms that are not yet officially added to Chef support matrix
property :platform_version_compatibility_mode, [true, false]

# Configure specific platform package
property :platform, String
property :platform_version, String
property :architecture, String

platform_family = node['platform_family']

action :install do
  add_config(new_resource.product_name, new_resource.config)
  declare_chef_run_stop_resource

  handle_install
end

action :upgrade do
  add_config(new_resource.product_name, new_resource.config)
  declare_chef_run_stop_resource

  handle_upgrade
end

action :uninstall do
  handle_uninstall
end

action :reconfigure do
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

action_class.class_eval do
  include ChefIngredientCookbook::Helpers

  case platform_family
  when 'debian', 'rhel', 'suse', 'windows'
    include ::ChefIngredient::DefaultHandler
  else
    # OmnitruckHandler is used for Solaris, AIX, FreeBSD, etc.
    # Eventually, we would like to support all platforms with the DefaultHandler
    include ::ChefIngredient::OmnitruckHandler
  end
end
