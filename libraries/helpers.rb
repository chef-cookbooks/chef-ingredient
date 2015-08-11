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

    def local_package_resource
      return :dpkg_package if node['platform_family'] == 'debian'
      return :rpm_package  if node['platform_family'] == 'rhel'
      :package # fallback if there's no platform match
    end

    def package_resource(ingredient_action)
      presource = new_resource.package_source.nil? ? :package : local_package_resource

      declare_resource presource, new_resource.product_name do
        package_name ingredient_package_name
        options new_resource.options
        version install_version if Mixlib::Versioning.parse(version_string(new_resource.version)) > '0.0.0'
        source new_resource.package_source
        timeout new_resource.timeout
        action ingredient_action
      end
    end

    def install_mixlib_versioning
      # We need Mixlib::Versioning in the library helpers for
      # parsing the version string.
      chef_gem "#{new_resource.product_name}-mixlib-versioning" do # ~FC009 foodcritic needs an update
        package_name 'mixlib-versioning'
        compile_time true
      end

      require 'mixlib/versioning'
    end

    def create_repository
      cleanup_old_repo_config if ::File.exist?(old_ingredient_repo_file)
      include_recipe "#{package_repo_type}-chef" if new_resource.package_source.nil?
    end

    def package_repo_type
      return 'apt' if node['platform_family'] == 'debian'
      return 'yum' if node['platform_family'] == 'rhel'
    end

    def rhel_major_version
      return node['platform_version'].to_i if node['platform_family'] == 'rhel'
      node['platform_version']
    end

    def install_version
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

    def old_ingredient_repo_file
      return '/etc/apt/sources.list.d/chef_stable_.list' if node['platform_family'] == 'debian'
      return '/etc/yum.repos.d/chef_stable_.repo' if node['platform_family'] == 'rhel'
    end

    def cleanup_old_repo_config
      file old_ingredient_repo_file do
        action :delete
      end
    end

    def ctl_command
      new_resource.ctl_command || chef_ctl_command(new_resource.product_name)
    end

    def reconfigure
      ctl_cmd = ctl_command
      execute "#{new_resource.product_name}-reconfigure" do
        command "#{ctl_cmd} reconfigure"
      end
    end

    # When updating this, also update PRODUCT_MATRIX.md
    def product_matrix
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
          'package-name' => 'chef-manage',
          'ctl-command'  => 'chef-manage-ctl',
          'config-file'  => '/etc/opscode-manage/manage.rb'
        },
        'private-chef' => {
          'package-name' => 'private-chef',
          'ctl-command'  => 'private-chef-ctl',
          'config-file'  => '/etc/opscode/private-chef.rb'
        },
        'push-client' => {
          'package-name' => 'chef-push-client',
          'ctl-command'  => nil,
          'config-file'  => nil
        },
        'push-server' => {
          'package-name' => 'chef-push-server',
          'ctl-command'  => 'chef-push-ctl',
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
          'config-file'  => '/etc/supermarket/supermarket.rb'
        }
      }
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
      if (product == 'chef-server')
        if (v < Mixlib::Versioning.parse('12.0.0')) && (v > Mixlib::Versioning.parse('11.0.0'))
          data['package-name'] = 'chef-server'
        elsif (v < Mixlib::Versioning.parse('11.0.0')) && (v > Mixlib::Versioning.parse('1.0.0'))
          Chef::Log.fatal("Invalid version specified, '#{version}' for #{product}!")
          fail
        end
      elsif (product == 'manage') && (v < Mixlib::Versioning.parse('2.0.0'))
        data['package-name'] = 'opscode-manage'
        data['ctl-command'] = 'opscode-manage-ctl'
      # TODO: When Chef Push server and client 2.0 are released, we
      # need to implement similar logic to chef-server, so that the
      # default "latest" version, 0.0.0 (no constraint) doesn't result
      # in the old package.
      elsif (product == 'push-server') && (v < Mixlib::Versioning.parse('2.0.0'))
        data['package-name'] = 'opscode-push-jobs-server'
        data['ctl-command'] = 'opscode-push-jobs-server-ctl'
      elsif (product == 'push-client') && (v < Mixlib::Versioning.parse('2.0.0'))
        data['package-name'] = 'opscode-push-jobs-client'
      end

      data
    end

    def add_config(product, content)
      return if content.nil?

      node.run_state[:ingredient_config_data] ||= {}
      node.run_state[:ingredient_config_data][product] ||= ''
      node.run_state[:ingredient_config_data][product] += content
    end

    def get_config(product)
      node.run_state[:ingredient_config_data] ||= {}
      node.run_state[:ingredient_config_data][product] ||= ''
    end
  end
end

module ChefServerIngredientsCookbook
  module Helpers
    include ChefIngredientCookbook::Helpers
    alias_method :chef_server_ctl_command, :chef_ctl_command
  end
end
