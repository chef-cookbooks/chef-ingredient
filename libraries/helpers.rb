#
# Author:: Joshua Timberman <joshua@chef.io>
# Copyright (c) 2014-2015, Chef Software, Inc. <legal@chef.io>
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

module ChefIngredientCookbook
  module Helpers
    def chef_ctl_command(product)
      if new_resource.respond_to?(:version)
        product_lookup(product, version_string(new_resource.version))['ctl-command']
      else
        product_lookup(product)['ctl-command']
      end
    end

    def version_string(vers)
      return '0.0.0' if vers.to_sym == :latest
      vers
    end

    def ingredient_package_name
      product_lookup(new_resource.product_name, version_string(new_resource.version))['package-name']
    end

    def ensure_mixlib_versioning_gem_installed!
      node.run_state[:mixlib_versioning_gem_installed] ||= begin # ~FC001
        install_gem_from_rubygems('mixlib-versioning', '1.1.0')

        require 'mixlib/versioning'
        true
      end
    end

    def ensure_mixlib_install_gem_installed!
      node.run_state[:mixlib_install_gem_installed] ||= begin # ~FC001
        install_gem_from_rubygems('mixlib-install', '0.8.0.alpha.0')

        require 'mixlib/install'
        true
      end
    end

    def install_gem_from_rubygems(gem_name, gem_version)
      Chef::Log.debug("Installing #{gem_name} v#{gem_version} from Rubygems.org")
      chefgem = Chef::Resource::ChefGem.new(gem_name, run_context)
      chefgem.version(gem_version)
      chefgem.run_action(:install)
    end

    def rhel_major_version
      return node['platform_version'].to_i if node['platform_family'] == 'rhel'
      node['platform_version']
    end

    def version_for_package_resource
      require 'mixlib/versioning'
      v = Mixlib::Versioning.parse(version_string(new_resource.version))
      version = "#{v.major}.#{v.minor}.#{v.patch}"
      version << "~#{v.prerelease}" if v.prerelease? && !v.prerelease.match(/^\d$/)
      version << "+#{v.build}" if v.build?
      version << '-1' unless version.match(/-1$/)
      version << rhel_append_version if node['platform_family'] == 'rhel' &&
                                        !version.match(/#{rhel_append_version}$/)
      version
    end

    def rhel_append_version
      ".el#{rhel_major_version}"
    end

    def ctl_command
      new_resource.ctl_command || chef_ctl_command(new_resource.product_name)
    end

    # Return the Product Matric in JSON format
    def product_matrix
      ChefIngredientCookbook::ProductMatrix.json
    end

    # Version has a default value of 0.0.0 so that it is a valid
    # string for the Mixlib::Versioning.parse method. This implies
    # "latest", but "latest" is not a value that is valid for
    # mixlib/versioning.
    def product_lookup(product, version = '0.0.0')
      unless product_matrix.key?(product)
        Chef::Log.fatal("We don't have a product, '#{product}'. Please specify a valid product name:")
        Chef::Log.fatal(product_matrix.keys.join(' '))
        fail
      end

      require 'mixlib/versioning'
      v = Mixlib::Versioning.parse(version_string(version))

      data = product_matrix[product]

      # We want to validate that we're getting a version that is valid
      # for the Chef Server. However, since the default is 0.0.0,
      # implying latest, we need to additionally ensure that the
      # bottom version is something valid. If we don't have the check
      # in the elsif, it will say that 0.0.0 is not a valid version.
      if product == 'chef-server'
        if (v < Mixlib::Versioning.parse('12.0.0')) && (v > Mixlib::Versioning.parse('11.0.0'))
          data['package-name'] = 'chef-server'
        elsif (v < Mixlib::Versioning.parse('11.0.0')) && (v > Mixlib::Versioning.parse('0.0.0'))
          Chef::Log.fatal("Invalid version specified, '#{version}' for #{product}!")
          fail
        end
      elsif (product == 'manage') && ((v < Mixlib::Versioning.parse('2.0.0')) && (v > Mixlib::Versioning.parse('0.0.0')))
        data['package-name'] = 'opscode-manage'
        data['ctl-command'] = 'opscode-manage-ctl'
      # TODO: When Chef Push server and client 2.0 are released, we
      # need to implement similar logic to chef-server, so that the
      # default "latest" version, 0.0.0 (no constraint) doesn't result
      # in the old package.
      elsif (product == 'push-server') && ((v < Mixlib::Versioning.parse('1.3.0')) && (v > Mixlib::Versioning.parse('0.0.0')))
        data['package-name'] = 'opscode-push-jobs-server'
        data['ctl-command'] = 'opscode-push-jobs-server-ctl'
      elsif (product == 'push-client') && ((v < Mixlib::Versioning.parse('1.3.0')) && (v > Mixlib::Versioning.parse('0.0.0')))
        data['package-name'] = 'opscode-push-jobs-client'
      end

      data
    end

    def add_config(product, content)
      return if content.nil?

      # FC001: Use strings in preference to symbols to access node attributes
      # foodcritic thinks we are accessing a node attribute
      node.run_state[:ingredient_config_data] ||= {}              # ~FC001
      node.run_state[:ingredient_config_data][product] ||= ''     # ~FC001
      node.run_state[:ingredient_config_data][product] += content unless node.run_state[:ingredient_config_data][product].include?(content) # ~FC001
    end

    def get_config(product)
      # FC001: Use strings in preference to symbols to access node attributes
      # foodcritic thinks we are accessing a node attribute
      node.run_state[:ingredient_config_data] ||= {}          # ~FC001
      node.run_state[:ingredient_config_data][product] ||= '' # ~FC001
    end

    def fqdn_resolves?(fqdn)
      require 'resolv'
      Resolv.getaddress(fqdn)
      return true
    rescue Resolv::ResolvError, Resolv::ResolvTimeout
      false
    end

    module_function :fqdn_resolves?

    def declare_chef_run_stop_resource
      # We do not supply an option to turn off stopping the chef client run
      # after a version change. As the gems shipped with omnitruck artifacts
      # change, chef-client runs *WILL* occasionally break on minor version
      # updates of chef, so we *MUST* stop the chef-client run when its version
      # changes. The gems versions that chef-client started with will not
      # necessarily exist after an upgrade.
      ruby_block 'stop chef run' do
        action :nothing
        block do
          Chef::Application.fatal! 'Chef version has changed during the run. Stopping the current Chef run. Please run chef again.'
        end
      end
    end
  end

  module ProductMatrix
    module_function

    # When updating this, also update PRODUCT_MATRIX.md
    def json
      {
        'analytics' => {
          'package-name' => 'opscode-analytics',
          'ctl-command'  => 'opscode-analytics-ctl',
          'config-file'  => '/etc/opscode-analytics/opscode-analytics.rb'
        },
        'chef' => {
          'package-name' => 'chef',
          'ctl-command'  => nil,
          'config-file'  => nil
        },
        'chef-ha' => {
          'package-name' => 'chef-ha',
          'ctl-command'  => nil,
          'config-file'  => '/etc/opscode/chef-server.rb'
        },
        'chef-marketplace' => {
          'package-name' => 'chef-marketplace',
          'ctl-command'  => 'chef-marketplace-ctl',
          'config-file'  => '/etc/chef-marketplace/marketplace.rb'
        },
        'chef-server' => {
          'package-name' => 'chef-server-core',
          'ctl-command'  => 'chef-server-ctl',
          'config-file'  => '/etc/opscode/chef-server.rb'
        },
        'chef-sync' => {
          'package-name' => 'chef-sync',
          'ctl-command'  => 'chef-sync-ctl',
          'config-file'  => '/etc/chef-sync/chef-sync.rb'
        },
        'chefdk' => {
          'package-name' => 'chefdk',
          'ctl-command'  => nil,
          'config-file'  => nil
        },
        'compliance' => {
          'package-name' => 'chef-compliance',
          'ctl-command'  => 'chef-compliance-ctl',
          'config-file'  => '/etc/chef-compliance/chef-compliance.rb'
        },
        'delivery' => {
          'package-name' => 'delivery',
          'ctl-command'  => 'delivery-ctl',
          'config-file'  => '/etc/delivery/delivery.rb'
        },
        'delivery-cli' => {
          'package-name' => 'delivery-cli',
          'ctl-command'  => nil,
          'config-file'  => nil
        },
        'manage' => {
          'package-name' => 'opscode-manage',
          'ctl-command'  => 'opscode-manage-ctl',
          'config-file'  => '/etc/opscode-manage/manage.rb'
        },
        'private-chef' => {
          'package-name' => 'private-chef',
          'ctl-command'  => 'private-chef-ctl',
          'config-file'  => '/etc/opscode/private-chef.rb'
        },
        'push-client' => {
          'package-name' => 'push-jobs-client',
          'ctl-command'  => nil,
          'config-file'  => nil
        },
        'push-server' => {
          'package-name' => 'opscode-push-jobs-server',
          'ctl-command'  => 'opscode-push-jobs-server-ctl',
          'config-file'  => '/etc/opscode-push-jobs-server/opscode-push-jobs-server.rb'
        },
        'reporting' => {
          'package-name' => 'opscode-reporting',
          'ctl-command'  => 'opscode-reporting-ctl',
          'config-file'  => '/etc/opscode-reporting/opscode-reporting.rb'
        },
        'supermarket' => {
          'package-name' => 'supermarket',
          'ctl-command'  => 'supermarket-ctl',
          'config-file'  => '/etc/supermarket/supermarket.json'
        }
      }
    end
  end
end

module ChefServerIngredientsCookbook
  module Helpers
    include ChefIngredientCookbook::Helpers
    alias_method :chef_server_ctl_command, :chef_ctl_command
  end
end
