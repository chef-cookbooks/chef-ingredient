#
# Author:: Serdar Sutay <serdar@chef.io>
# Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>
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

module ChefIngredient
  module DebianHandler
    def handle_install
      configure_package(:install)
    end

    def handle_upgrade
      configure_package(:upgrade)
    end

    def handle_uninstall
      package ingredient_package_name do
        action :remove
      end
    end

    private

    def configure_package(action_name)
      byop = !node['chef-ingredient'].nil? && \
             !node['chef-ingredient']['byop'].nil? && \
             node['chef-ingredient']['byop'] == true
      # This is to cleanup old cruft from chef-server-ingredient
      file '/etc/apt/sources.list.d/chef_stable_.list' do
        action :delete
        only_if { ::File.exist?('/etc/apt/sources.list.d/chef_stable_.list') }
      end

      if new_resource.package_source
        dpkg_package new_resource.product_name do
          action action_name
          package_name ingredient_package_name
          options new_resource.options
          source new_resource.package_source

          if new_resource.product_name == 'chef'
            # We define this resource in ChefIngredientProvider
            notifies :run, 'ruby_block[stop chef run]', :immediately
          end
        end
      else
        # Enable the required apt-repository.
        include_recipe "apt-chef::#{new_resource.channel}" unless byop

        # Pin it so that product can only be installed from its own channel
        apt_preference ingredient_package_name do
          pin "release o=https://packagecloud.io/chef/#{new_resource.channel}"
          pin_priority '900'
          not_if { byop }
        end

        # Foodcritic doesn't like timeout attribute in package resource
        package new_resource.product_name do # ~FC009
          action action_name
          package_name ingredient_package_name
          options new_resource.options
          timeout new_resource.timeout

          # If the user specifies "0.0.0", :latest or "latest" as version,
          # we should not give any version to the package resource.
          if Mixlib::Versioning.parse(version_string(new_resource.version)) > '0.0.0'
            version version_for_package_resource
          end

          if new_resource.product_name == 'chef'
            # We define this resource in ChefIngredientProvider
            notifies :run, 'ruby_block[stop chef run]', :immediately
          end
        end
      end
    end
  end
end
