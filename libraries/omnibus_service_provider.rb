#
# Author:: Joshua Timberman <joshua@chef.io
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

require_relative './helpers'

class Chef
  class Provider
    class OmnibusService < Chef::Provider::LWRPBase
      provides :omnibus_service
      # Methods for use in resources, found in helpers.rb
      include ChefIngredientCookbook::Helpers

      use_inline_resources

      def whyrun_supported?
        true
      end

      %w(start stop restart hup int kill graceful-kill once).each do |sv_command|
        action sv_command.tr('-', '_').to_sym do
          execute "#{omnibus_ctl_command} #{sv_command} #{omnibus_service_name.last}"
        end
      end

      private

      def omnibus_ctl_command
        new_resource.ctl_command || chef_ctl_command(omnibus_service_name.first)
      end

      def omnibus_service_name
        new_resource.service_name.split('/')
      end
    end
  end
end
