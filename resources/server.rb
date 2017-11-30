#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: server
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

resource_name 'chef_server'

property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :config, String, required: true
property :accept_license, [TrueClass, FalseClass], default: false
property :addons, Hash, default: {}
property :data_collector_token, String, default: '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'
property :data_collector_url, String
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  if new_resource.data_collector_url
    new_resource.config << "\ndata_collector['root_url'] = '#{new_resource.data_collector_url}'"
    new_resource.config << "\ndata_collector['token'] = '#{new_resource.data_collector_token}'"
  end
  chef_ingredient 'chef-server' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    config new_resource.config
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
    sensitive new_resource.sensitive if new_resource.sensitive
  end

  ingredient_config 'chef-server' do
    sensitive new_resource.sensitive if new_resource.sensitive
    notifies :reconfigure, 'chef_ingredient[chef-server]', :immediately
  end

  new_resource.addons.each do |addon, options|
    chef_ingredient addon do
      action :upgrade
      channel options['channel'] || :stable
      version options['version'] || :latest
      config options['config'] || ''
      accept_license new_resource.accept_license
      platform new_resource.platform if new_resource.platform
      platform_version new_resource.platform_version if new_resource.platform_version
      sensitive new_resource.sensitive if new_resource.sensitive
    end

    ingredient_config addon do
      sensitive new_resource.sensitive if new_resource.sensitive
      notifies :reconfigure, "chef_ingredient[#{addon}]", :immediately
    end
  end
end

action_class do
  include ChefIngredientCookbook::Helpers
end
