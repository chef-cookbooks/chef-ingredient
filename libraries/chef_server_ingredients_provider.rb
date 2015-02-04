#
# Author:: Joshua Timberman <joshua@getchef.com
# Copyright (c) 2014, Chef Software, Inc. <legal@getchef.com>
#
# Portions from https://github.com/computology/packagecloud-cookbook:
# Copyright (c) 2014, Computology, LLC.
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

require 'uri'
require 'pathname'

class Chef
  class Provider
    class ChefServerIngredient < Chef::Provider::LWRPBase
      # FIXME: (jtimberman) remove this include when we switch to packagecloud_repo.
      require_relative './helpers'
      include ::PackageCloud::Helper

      use_inline_resources

      def whyrun_supported?
        true
      end

      def load_current_resource
        self.current_resource = Chef::Resource::ChefServerIngredient.new(new_resource.name)
        current_resource.package_name(new_resource.package_name)
        current_resource
      end

      action :install do
        packagecloud_repo 'chef/stable' do
          type value_for_platform_family(:debian => 'deb', :rhel => 'rpm')
        end

        package new_resource.package_name do
          options new_resource.options
          version new_resource.version
        end
        
        if new_resource.reconfigure
          ctl_cmd = ctl_command
          execute "#{new_resource.package_name}-reconfigure" do
            command "#{ctl_cmd} reconfigure"
          end
        end
      end

      action :uninstall do
        package new_resource.package_name do
          action :remove
        end
      end

      action :remove do
        action_uninstall
      end

      action :reconfigure do
        ctl_cmd = ctl_command
        execute "#{new_resource.package_name}-reconfigure" do
          command "#{ctl_cmd} reconfigure"
        end
      end

      private

      def ctl_command
        new_resource.ctl_command || chef_server_ctl_command(new_resource.package_name)
      end

      def reconfigure
        ctl_cmd = ctl_command
        execute "#{new_resource.package_name}-reconfigure" do
          command "#{ctl_cmd} reconfigure"
        end
      end

    end
  end
end