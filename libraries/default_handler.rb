#
# Author:: Serdar Sutay <serdar@chef.io>
# Author:: Patrick Wright <patrick@chef.io>
#
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
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
  module DefaultHandler
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
      if new_resource.package_source
        configure_from_source_package(action_name)
      elsif use_custom_repo_recipe?
        # Use the custom repository recipe.
        include_recipe custom_repo_recipe
        configure_from_repo(action_name)
      else
        configure_from_channel(action_name)
      end
    end

    def configure_from_source_package(action_name, local_path = nil)
      package new_resource.product_name do
        action action_name
        package_name ingredient_package_name
        options new_resource.options
        source local_path || new_resource.package_source
        provider value_for_platform_family(
          'debian'  => Chef::Provider::Package::Dpkg,
          'rhel'    => Chef::Provider::Package::Rpm,
          'windows' => Chef::Provider::Package::Windows
        )
        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end
    end

    def configure_from_repo(action_name)
      # Foodcritic doesn't like timeout attribute in package resource
      package new_resource.product_name do # ~FC009
        action action_name
        package_name ingredient_package_name
        options package_options_with_force
        timeout new_resource.timeout

        # If the latest version is specified, we should not give any version
        # to the package resource.
        unless version_latest?(new_resource.version)
          version version_for_package_resource
        end

        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end
    end

    def configure_from_channel(action_name)
      cache_path = Chef::Config[:file_cache_path]

      artifact_info = installer.artifact_info

      if artifact_info == []
        raise <<-EOH
No package found for '#{new_resource.product_name}' with version '#{new_resource.version}' for current platform in '#{new_resource.channel}' channel.
Check that the package exists.
        EOH
      end
      remote_artifact_path = artifact_info.url
      local_artifact_path = File.join(cache_path, ::File.basename(remote_artifact_path))

      converge_by "Download #{new_resource.product_name} package from #{remote_artifact_path}\n" do
        remote_file local_artifact_path do
          source remote_artifact_path
          mode '0644'
          checksum installer.artifact_info.sha256
        end
      end

      configure_from_source_package(action_name, local_artifact_path)
    end
  end
end
