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
  class RhelHandler
    def install
      configure_package(:upgrade)
    end

    def upgrade
      configure_package(:upgrade)
    end

    def uninstall
      package ingredient_package_name do
        action :remove
      end
    end

    private
    def configure_package(action_name)
      # TODO: Hrmmm this is interesting? stable? delete this every time?
      file '/etc/yum.repos.d/chef_stable_.repo' do
        action :delete
        only_if { ::File.exist?('/etc/apt/sources.list.d/chef_stable_.list') }
      end

      if new_resource.package_source
        rpm_package new_resource.product_name do
          action action_name
          package_name ingredient_package_name
          options new_resource.options
          source new_resource.package_source

          if new_resource.product_name == 'chef'
            notifies :run, 'ruby_block[stop chef run]', :immediately
          end
        end
      else
        include_recipe 'yum-chef'

        package new_resource.product_name do
          action action_name
          package_name ingredient_package_name
          options new_resource.options
          # TODO: Hrmmm not sure why are we fucking with the given version this much.
          version install_version if Mixlib::Versioning.parse(version_string(new_resource.version)) > '0.0.0'
          timeout new_resource.timeout

          if new_resource.product_name == 'chef'
            notifies :run, 'ruby_block[stop chef run]', :immediately
          end
        end
      end
    end
  end
end
