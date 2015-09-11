#
# Author:: Joshua Timberman <joshua@chef.io
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

require_relative './helpers'

class Chef
  class Provider
    class ChefIngredient < Chef::Provider::LWRPBase
      provides :chef_ingredient
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
        install_mixlib_versioning
        create_repository
        package_resource(:install)
        add_config(new_resource.product_name, new_resource.config)
      end

      action :upgrade do
        install_mixlib_versioning
        create_repository
        package_resource(:upgrade)
        add_config(new_resource.product_name, new_resource.config)
      end

      action :uninstall do
        install_mixlib_versioning
        package ingredient_package_name do
          action :remove
        end
      end

      action :remove do
        install_mixlib_versioning
        package ingredient_package_name do
          action :remove
        end
      end

      action :reconfigure do
        install_mixlib_versioning
        add_config(new_resource.product_name, new_resource.config)

        execute "#{ingredient_package_name}-reconfigure" do
          command "#{ctl_command} reconfigure"
        end
      end
    end
  end
end
