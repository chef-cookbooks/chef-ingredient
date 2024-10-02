#
# Author:: Joshua Timberman <joshua@chef.io
# Copyright:: 2015-2021, Chef Software, Inc. <legal@chef.io>
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

provides :omnibus_service
resource_name :omnibus_service

unified_mode true if respond_to?(:unified_mode)

default_action :nothing

property :ctl_command, String
property :service_name, String, regex: %r{[\w-]+\/[\w-]+}, name_property: true

# Install mixlib-install/version gems from rubygems.org or an alternative source
property :rubygems_url, String
property :mixlib_install_git_ref, String
property :mixlib_install_version, String # default nil installs latest

%w(start stop restart hup int kill graceful-kill once).each do |sv_command|
  action sv_command.tr('-', '_').to_sym do
    execute "#{omnibus_ctl_command} #{sv_command} #{raw_service_name}"
  end
end

action_class do
  include ChefIngredientCookbook::Helpers

  #
  # Returns the ctl-command to be used when executing commands for the
  # service.
  #
  def omnibus_ctl_command
    product_key_for_service = new_resource.service_name.split('/').first
    new_resource.ctl_command || ctl_command_for_product(product_key_for_service)
  end

  #
  # Returns the raw service name
  #
  def raw_service_name
    new_resource.service_name.split('/').last
  end
end
