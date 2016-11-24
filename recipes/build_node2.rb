#
# Cookbook Name:: chef
# Recipe:: build_node
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

chef_client node['fqdn'] do
  action [:install, :configure, :register]
  version '12.15.19'
  chef_server_url 'https://chef.local/organizations/infrastructure'
  run_list ['recipe[chef::build_node2]']
  environment '_default'
  validation_client_name 'infrastructure-validator'
  validation_pem 'file:///tmp/config/validation.pem'
  ssl_verify true
  interval 1800
  splay 1800
end

workflow_builder node['fqdn'] do
  version '1.0.3'
  pj_version '2.1.3'
  accept_license true
  chef_user 'workflow'
  chef_user_pem 'file:///tmp/config/workflow.pem'
  builder_pem 'file:///tmp/config/builder.pem'
  chef_fqdn 'chef.local'
  automate_fqdn 'automate.local'
  supermarket_fqdn 'supermarket.local'
  job_dispatch_version 'v1'
  automate_user 'admin'
  automate_password ::File.read('/tmp/config/chef.creds')[/Admin password: (?<pw>.*)$/, 'pw']
  not_if { node['tags'].include?('kitchen') }
end
