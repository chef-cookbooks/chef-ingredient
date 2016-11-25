#
# Cookbook Name:: chef
# Recipe:: client
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
  action [:install, :register]
  version :latest
  chef_server_url 'https://chef.local/organizations/infrastructure'
  run_list node['expanded_run_list'].reject { |item| item.eql?('chef::_kitchen') }
  environment '_default'
  validation_client_name 'infrastructure-validator'
  validation_pem 'file:///tmp/config/validation.pem'
  ssl_verify true
  interval 1800
  splay 1800
#  data_collector_url 'https://automate.local/data-collector/v0/'
end
