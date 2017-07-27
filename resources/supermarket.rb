#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: supermarket
#
# Copyright:: 2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name 'chef_supermarket'
default_action :create

property :name, String, name_property: true
property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :config, Hash, default: {}
property :chef_server_url, String, default: Chef::Config['chef_server_url']
property :chef_oauth2_app_id, String, required: true
property :chef_oauth2_secret, String, required: true
property :chef_oauth2_verify_ssl, [TrueClass, FalseClass], default: true
property :accept_license, [TrueClass, FalseClass], default: false
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  chef_ingredient 'supermarket' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    config JSON.pretty_generate(
      new_resource.config.merge(
        chef_server_url: new_resource.chef_server_url,
        chef_oauth2_app_id: new_resource.chef_oauth2_app_id,
        chef_oauth2_secret: new_resource.chef_oauth2_secret,
        chef_oauth2_verify_ssl: new_resource.chef_oauth2_verify_ssl
      )
    )
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  ingredient_config 'supermarket' do
    notifies :reconfigure, 'chef_ingredient[supermarket]', :immediately
  end
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
