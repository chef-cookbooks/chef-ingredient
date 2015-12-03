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
require_relative './debian_handler'
require_relative './rhel_handler'
require_relative './omnitruck_handler'

class Chef
  class Provider
    class ChefIngredient < Chef::Provider::LWRPBase
      provides :chef_ingredient
      use_inline_resources

      # for using include_recipe
      require 'chef/dsl/include_recipe'
      include Chef::DSL::IncludeRecipe
      include ChefIngredientCookbook::Helpers

      def whyrun_supported?
        true
      end

      def initialize(name, run_context = nil)
        super(name, run_context)
        case node['platform_family']
        when 'debian'
          extend ::ChefIngredient::DebianHandler
        when 'rhel'
          extend ::ChefIngredient::RhelHandler
        else
          extend ::ChefIngredient::OmnitruckHandler
        end
      end

      action :install do
        add_config(new_resource.product_name, new_resource.config)
        declare_chef_run_stop_resource

        handle_install
      end

      action :upgrade do
        add_config(new_resource.product_name, new_resource.config)
        declare_chef_run_stop_resource

        handle_upgrade
      end

      action :uninstall do
        handle_uninstall
      end

      action :reconfigure do
        add_config(new_resource.product_name, new_resource.config)

        if ingredient_ctl_command.nil?
          Chef::Log.warn "Product '#{new_resource.product_name}' does not support reconfigure."
          Chef::Log.warn 'chef_ingredient is skipping :reconfigure.'
        else
          # Render the config in case it is not rendered yet
          ingredient_config new_resource.product_name do
            action :render
            not_if { get_config(new_resource.product_name).empty? }
          end

          execute "#{ingredient_package_name}-reconfigure" do
            command "#{ingredient_ctl_command} reconfigure"
          end
        end
      end
    end
  end
end
