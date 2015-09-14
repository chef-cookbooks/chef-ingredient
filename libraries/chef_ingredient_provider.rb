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
      attr_reader :action_handler

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

      def initialize
        @action_handler = case node['platform_family']
        when 'debian'
          ChefIngredient::DebianHandler.new
        when 'rhel'
          ChefIngredient::RhelHandler.new
        else
          ChefIngredient::OmnitruckHandler.new
        end

        super
      end

      action :install do
        install_mixlib_versioning
        add_config(new_resource.product_name, new_resource.config)

        action_handler.install
      end

      action :upgrade do
        install_mixlib_versioning
        add_config(new_resource.product_name, new_resource.config)

        action_handler.upgrade
      end

      action :uninstall do
        install_mixlib_versioning
        action_handler.uninstall
      end

      alias_method :remove, :uninstall

      action :reconfigure do
        install_mixlib_versioning
        add_config(new_resource.product_name, new_resource.config)

        if ctl_command.nil?
          Chef::Log.warn "Product '#{new_resource.product_name}' does not support reconfigure."
          Chef::Log.warn 'chef_ingredient is skipping :reconfigure.'
        else
          execute "#{ingredient_package_name}-reconfigure" do
            command "#{ctl_command} reconfigure"
          end
        end
      end
    end
  end
end
