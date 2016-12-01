#
# Cookbook Name:: chef
# Recipe:: automate
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

include_recipe 'chef::client'

chef_automate node['fqdn'] do
  version :latest
  config <<-EOF
    delivery_fqdn "automate.local"
    delivery['chef_server'] = 'https://chef.local/organizations/infrastructure'
    insights['enable'] = true
  EOF
  accept_license true
  enterprise 'chef'
  license 'file:///tmp/config/delivery.license'
  chef_user 'workflow'
  chef_user_pem 'file:///tmp/config/workflow.pem'
  validation_pem 'file:///tmp/config/validation.pem'
  builder_pem 'file:///tmp/config/builder.pem'
  not_if { node['tags'].include?('kitchen') }
end

file '/tmp/config/chef.creds' do
  content lazy { ::File.read('/etc/delivery/chef.creds') }
  only_if { node['tags'].include?('kitchen') }
end

log 'Automate Credentials' do
  message lazy { ::File.read('/etc/delivery/chef.creds') }
end
