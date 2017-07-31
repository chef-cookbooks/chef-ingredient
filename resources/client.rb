#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: client
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
# rubocop:disable ParenthesesAsGroupedExpression

resource_name 'chef_client'
default_action :install

property :node_name, String, name_property: true
property :version, [String, Symbol], default: :latest
property :chefdk, [TrueClass, FalseClass], default: false
property :chef_server_url, [String, Symbol], default: :local
property :ssl_verify, [TrueClass, FalseClass], default: true
property :log_location, String, default: 'STDOUT'
property :log_level, Symbol, default: :auto
property :config, String
property :run_list, Array
property :environment, String
property :validation_pem, String
property :validation_client_name, String
property :tags, [String, Array], default: ''
property :interval, Integer, default: 1800
property :splay, Integer, default: 1800
property :data_collector_token, String, default: '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'
property :data_collector_url, String
property :platform, String
property :platform_version, String

load_current_value do
  version Chef::VERSION
  chef_server_url Chef::Config['chef_server_url']
  ssl_verify (Chef::Config['ssl_verify_mode'].eql?(:verify_peer) ? true : false)
  if Chef::Config['log_location'].is_a?(IO)
    log_location Chef::Config['log_location'].inspect[/#<IO:<(?<stream>.*)>>/, 'stream']
  else
    log_location Chef::Config['log_location']
  end
  log_level Chef::Config['log_level']
  if ::File.exist?(::File.join(Chef::Config[:config_d_dir], 'custom.rb'))
    config ::File.read(::File.join(Chef::Config[:config_d_dir], 'custom.rb'))
  end
  run_list node['recipes']
end

action :install do
  chef_ingredient 'chef' do
    action :upgrade
    version new_resource.version
    not_if { new_resource.chefdk }
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  chef_ingredient 'chefdk' do
    action :upgrade
    version new_resource.version
    only_if { new_resource.chefdk }
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  directory ::File.join(prefix, 'config.d') do
    mode '0755'
    recursive true
  end

  template 'client.rb' do
    source 'client.rb.erb'
    path ::File.join(prefix, 'client.rb')
    cookbook 'chef-ingredient'
    mode '0640'
    variables node_name: new_resource.node_name,
              chef_server_url: new_resource.chef_server_url,
              ssl_verify: new_resource.ssl_verify,
              log_location: new_resource.log_location,
              log_level: new_resource.log_level,
              validation_client_name: new_resource.validation_client_name,
              json_attribs: ::File.join(prefix, 'dna.json'),
              data_collector_url: new_resource.data_collector_url,
              data_collector_token: new_resource.data_collector_token
  end

  rl = {}
  rl = rl.merge(run_list: new_resource.run_list) if new_resource.run_list
  rl = rl.merge(environment: new_resource.environment) if new_resource.environment
  file 'dna.json' do
    path ::File.join(prefix, 'dna.json')
    content rl.to_json
  end

  file 'custom.rb' do
    path ::File.join(prefix, 'config.d', 'custom.rb')
    content new_resource.config
    mode '0640'
    only_if { new_resource.config }
  end

  chef_file ::File.join(prefix, 'validation.pem') do
    source new_resource.validation_pem
    user 'root'
    group 'root'
    mode '0600'
    not_if { ::File.exist?(::File.join(prefix, 'client.pem')) }
    only_if { new_resource.property_is_set?(:validation_pem) }
  end
end

action :register do
  execute 'fetch ssl certificates' do
    command "knife ssl fetch -c #{::File.join(prefix, 'client.rb')}"
    not_if "knife ssl check -c #{::File.join(prefix, 'client.rb')}"
  end

  execute 'register with chef-server' do
    command "chef-client -j #{::File.join(prefix, 'dna.json')}"
    live_stream true
    not_if { ::File.exist?(::File.join(prefix, 'client.pem')) }
  end

  # ruby_block 'update run_list' do
  #   block do
  #     rest = Chef::REST.new(Chef::Config[:chef_server_url])
  #     org = Chef::Config[:chef_server_url].split('/')[-1]
  #     rest.post("/organizations/#{org}/nodes/#{node['fqdn']}", '{"run_list": [new_resource.run_list]}')
  #   end
  #   not_if { new_resource.run_list.eql?(current_resource.run_list) }
  # end

  file 'delete validation.pem' do
    action :delete
    path ::File.join(prefix, 'validation.pem')
  end

  execute 'add tags to node' do
    command "knife tag create #{node['fqdn']} #{(tags.is_a?(Array) ? tags.join(' ') : tags)} -c /etc/chef/client.rb -u #{node['fqdn']}"
    not_if { tags.eql?('') }
  end
end

action :run do
  execute 'chef-client' do
    live_stream true
  end
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
