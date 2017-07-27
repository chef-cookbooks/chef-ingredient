#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: chef_user
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

resource_name 'chef_user'
default_action :create

property :username, String, name_property: true
property :first_name, String, required: true
property :last_name, String, required: true
property :email, String, required: true
property :password, String
property :key_path, String
property :serveradmin, [TrueClass, FalseClass], default: false

load_current_value do
  node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  directory '/etc/opscode/users' do
    owner 'root'
    group 'root'
    mode '0700'
    recursive true
  end

  key = (property_is_set?(:key_path) ? new_resource.key_path : "/etc/opscode/users/#{new_resource.username}.pem")
  password = (property_is_set?(:password) ? new_resource.password : SecureRandom.base64(36))

  execute "create-user-#{new_resource.username}" do
    sensitive true
    retries 3
    command "chef-server-ctl user-create #{new_resource.username} #{new_resource.first_name} #{new_resource.last_name} #{new_resource.email} #{password} -f #{key}"
    not_if { node.run_state['chef-users'].index(/^#{new_resource.username}$/) }
  end

  ruby_block 'append-user-to-users' do
    block do
      node.run_state['chef-users'] << "#{new_resource.username}\n"
    end
  end

  execute "grant-server-admin-#{new_resource.username}" do
    command "chef-server-ctl grant-server-admin-permissions #{new_resource.username}"
    only_if { new_resource.serveradmin }
  end
end

action :delete do
  execute "delete-user-#{new_resource.username}" do
    retries 3
    command "chef-server-ctl user-delete #{new_resource.username} --yes --remove-from-admin-groups"
    only_if { node.run_state['chef-users'].index(/^#{new_resource.username}$/) }
  end

  ruby_block 'delete-user-to-users' do
    block do
      node.run_state['chef-users'] = node.run_state['chef-users'].gsub(/#{new_resource.username}\n/, '')
    end
  end
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
