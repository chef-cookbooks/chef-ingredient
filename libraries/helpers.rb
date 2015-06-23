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
      return '0.0.0' if vers == :latest || vers == 'latest'
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
      new_resource.ctl_command || chef_ctl_command(new_resource.package_name)
    end

    def reconfigure
      ctl_cmd = ctl_command
      execute "#{new_resource.package_name}-reconfigure" do
        command "#{ctl_cmd} reconfigure"
      end
    end

    # When updating this, also update PRODUCT_MATRIX.md
    def product_matrix
      {
        'analytics'    => { 'package-name' => 'opscode-analytics', 'ctl-command' => 'opscode-analytics-ctl' },
        'chef'         => { 'package-name' => 'chef',              'ctl-command' => nil                     },
        'chef-ha'      => { 'package-name' => 'chef-ha',           'ctl-command' => nil                     },
        'chef-server'  => { 'package-name' => 'chef-server-core',  'ctl-command' => 'chef-server-ctl'       },
        'chef-sync'    => { 'package-name' => 'chef-sync',         'ctl-command' => 'chef-sync-ctl'         },
        'chefdk'       => { 'package-name' => 'chefdk',            'ctl-command' => nil                     },
        'delivery'     => { 'package-name' => 'delivery',          'ctl-command' => 'delivery-ctl'          },
        'delivery-cli' => { 'package-name' => 'delivery-cli',      'ctl-command' => nil                     },
        'manage'       => { 'package-name' => 'chef-manage',       'ctl-command' => 'chef-manage-ctl'       },
        'private-chef' => { 'package-name' => 'private-chef',      'ctl-command' => 'private-chef-ctl'      },
        'push-client'  => { 'package-name' => 'chef-push-client',  'ctl-command' => nil                     },
        'push-server'  => { 'package-name' => 'chef-push-server',  'ctl-command' => 'chef-push-ctl'         },
        'reporting'    => { 'package-name' => 'opscode-reporting', 'ctl-command' => 'opscode-reporting-ctl' },
        'supermarket'  => { 'package-name' => 'supermarket',       'ctl-command' => 'supermarket-ctl'       }
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
      elsif (product == 'push-server') && (v < Mixlib::Versioning.parse('2.0.0'))
        data['package-name'] = 'chef-push-server'
        data['ctl-command'] = 'chef-push-ctl'
      elsif (product == 'push-client') && (v < Mixlib::Versioning.parse('2.0.0'))
        data['package-name'] = 'chef-push-client'
      end

      data
    end
  end
end

module ChefServerIngredientsCookbook
  module Helpers
    include ChefIngredientCookbook::Helpers
    alias_method :chef_server_ctl_command, :chef_ctl_command
  end
end
