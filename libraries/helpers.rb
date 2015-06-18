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
    # FIXME: (jtimberman) make this data we can change / use without
    # having to update the library code (e.g., if we create new
    # add-ons, or change any of these in the future).
    def chef_ctl_command(pkg)
      ctl_cmds = {
        'chef-server-core' => 'chef-server-ctl',
        'opscode-manage' => 'opscode-manage-ctl',
        'opscode-push-jobs-server' => 'opscode-push-jobs-server-ctl',
        'opscode-reporting' => 'opscode-reporting-ctl',
        'opscode-analytics' => 'opscode-analytics-ctl',
        'chef-sync' => 'chef-sync-ctl',
        'supermarket' => 'supermarket-ctl'
      }
      ctl_cmds[pkg]
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
      v = Mixlib::Versioning.parse(new_resource.version)
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
  end
end

module ChefServerIngredientsCookbook
  module Helpers
    include ChefIngredientCookbook::Helpers
    alias_method :chef_server_ctl_command, :chef_ctl_command
  end
end
