#
# Cookbook Name:: chef_stack
# Library:: helpers
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

def prefix
  (platform_family?('windows') ? 'C:/Chef/' : '/etc/chef/')
end

def ensurekv(config, hash)
  hash.each do |k, v|
    if config =~ /^ *#{v}.*$/
      config.sub(/^ *#{v}.*$/, "#{k} '#{v}'")
    else
      config << "\n#{k} '#{v}'"
    end
  end
  config
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def read_vault()
  ChefVault::Item.load('chef_stack', node.chef_environment)
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def write_vault(data)
  item = read_vault || ChefVault::Item.new(
    'chef_stack',
    node.chef_environment,
    node_name: node['chef_stack']['admin'],
    client_key_path: '/etc/opscode/users/workflow.pem'
  )
  item.raw_data ||= { 'id' => node.chef_environment }
  item.raw_data.merge!(data)
  item.search("chef_environment:#{node.chef_environment} AND recipe:chef_backend")
  item.clients("chef_environment:#{node.chef_environment} AND recipe:chef_backend")
  item.admins(node['chef_stack']['admin'])
  item.save
end
