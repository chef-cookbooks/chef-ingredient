#
# Author:: Joshua Timberman <joshua@getchef.com
# Copyright (c) 2014-2015, Chef Software, Inc. <legal@getchef.com>
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

class Chef
  class Provider
    class ChefIngredient < Chef::Provider::LWRPBase
      # for include_recipe
      require 'chef/dsl/include_recipe'
      include Chef::DSL::IncludeRecipe

      # Methods for use in resources, found in helpers.rb
      include ChefIngredientCookbook::Helpers

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :install do
        if new_resource.version
          # We need Mixlib::Versioning in the library helpers for
          # parsing the version string. But only if the version is
          # specified!
          chef_gem 'mixlib-versioning' do
            compile_time true
          end

          require 'mixlib/versioning'
        end

        cleanup_old_repo_config if ::File.exist?(old_ingredient_repo_file)
        include_recipe "#{package_repo_type}-chef" if new_resource.package_source.nil?

        package_resource = new_resource.package_source.nil? ? :package : local_package_resource

        declare_resource package_resource, new_resource.package_name do
          options new_resource.options
          version install_version if new_resource.version
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
