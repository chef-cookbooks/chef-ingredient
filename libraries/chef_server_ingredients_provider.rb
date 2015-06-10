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

require_relative './helpers'
require 'uri'
require 'pathname'

class Chef
  class Provider
    class ChefServerIngredient < Chef::Provider::LWRPBase
      # Methods for use in resources, found in helpers.rb
      include ChefServerIngredientsCookbook::Helpers
      # FIXME: (jtimberman) remove this include when we switch to packagecloud_repo.
      # QUESTION: (someara) is this still needed?
      include PackageCloud::Helper

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :install do
        # FIXME: Create yum-chef and apt-chef cookbooks and set
        # installation location with node attributes for use behind
        # firewalls.
        # See yum-centos, yum-epel, etc for examples.

        # TODO: create manage_package_repo boolean on resource
        # add another only_if
        packagecloud_repo new_resource.repository do
          type value_for_platform_family(debian: 'deb', rhel: 'rpm')
          only_if { new_resource.package_source.nil? }
        end

        package_resource = new_resource.package_source.nil? ? :package : local_package_resource

        declare_resource package_resource, new_resource.package_name do
          options new_resource.options
          version new_resource.version
          source new_resource.package_source
          timeout new_resource.timeout
        end
      end

      action :uninstall do
        package new_resource.package_name do
          action :remove
        end
      end

      action :remove do
        package new_resource.package_name do
          action :remove
        end
      end

      action :reconfigure do
        execute "#{new_resource.package_name}-reconfigure" do
          command "#{ctl_command} reconfigure"
        end
      end
    end
  end
end
