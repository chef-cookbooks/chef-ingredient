
# Cookbook Name:: chef_stack
# Resource:: backend
#
# Copyright 2016 Chef Software Inc
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
# rubocop:disable LineLength

resource_name 'chef_backend'
default_action :create

property :name, String, name_property: true
property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :config, String, default: ''
property :accept_license, [TrueClass, FalseClass], default: false
property :bootstrap_node, String, required: true
property :publish_address, String, default: node['ipaddress']
property :chef_backend_secrets, String
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  raise 'Must accept the Chef License agreement before continuing.' unless new_resource.accept_license

  new_resource.config = ensurekv(new_resource.config, publish_address: new_resource.publish_address)
  chef_ingredient 'chef-backend' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    config new_resource.config # TODO: Figure out why this isn't working in chef-ingredient
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  file '/etc/chef-backend/chef-backend.rb' do
    content new_resource.config
  end

  if new_resource.property_is_set?(:chef_backend_secrets)
    chef_file '/etc/chef-backend/chef-backend-secrets.json' do
      source new_resource.chef_backend_secrets
      user 'root'
      group 'root'
      mode '0600'
      not_if { node['fqdn'].eql?(new_resource.bootstrap_node) }
    end
  end

  execute 'chef-backend-ctl create-cluster --accept-license --yes' do
    only_if { node['fqdn'].eql?(new_resource.bootstrap_node) }
    not_if 'chef-backend-ctl cluster-status'
  end

  execute "chef-backend-ctl join-cluster #{new_resource.bootstrap_node} --accept-license --yes" do
    not_if { node['fqdn'].eql?(new_resource.bootstrap_node) }
    not_if 'chef-backend-ctl cluster-status'
  end
end
