#
# Cookbook Name:: chef
# Recipe:: server
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
  action [:install, :configure]
  version :latest
  chef_server_url 'https://chef-centos-72/organizations/infrastructure'
  run_list ['recipe[chef::server]']
  environment '_default'
  validation_client_name 'infrastructure-validator'
  validation_pem 'file:///tmp/config/validation.pem'
  ssl_verify false
  interval 1800
  splay 1800
  data_collector_url 'https://automate.local/data-collector/v0/'
end

chef_server node['fqdn'] do
  version :latest
  config <<-EOS
topology 'standalone'
ip_version 'ipv4'
api_fqdn 'chef.local'
oc_id['applications'] = {
  "supermarket"=>{"redirect_uri"=>"https://supermarket.local/auth/chef_oauth2/callback"}
}
EOS
  addons manage: { version: '2.4.3', config: '' },
         :"push-jobs-server" => { version: '2.1.0', config: '' }
  accept_license true
  data_collector_url 'https://automate.local/data-collector/v0/'
end

%w(/etc/opscode/users /etc/opscode/orgs).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0700'
    recursive true
  end
end

workflow_password = SecureRandom.base64(36)
file '/etc/opscode/users/workflow.password' do
  sensitive true
  content workflow_password
  not_if { ::File.exist?('/etc/opscode/users/workflow.password') }
end

file '/etc/opscode/users/builder.pem' do
  content OpenSSL::PKey::RSA.new(2048).to_pem
  not_if { ::File.exist?('/etc/opscode/users/builder.pem') }
end

chef_user 'workflow' do
  # sensitive true
  first_name 'Workflow'
  last_name 'Administrator'
  email 'success@chef.io'
  password workflow_password
end

chef_org 'infrastructure' do
  admins ['workflow']
  users []
end

directory "#{ENV['HOME']}/.chef"

file "#{ENV['HOME']}/.chef/knife.rb" do
  content <<-EOS
  chef_server_url "https://#{node['fqdn']}/organizations/infrastructure"
  verify_api_cert false
  ssl_verify_mode :verify_none
  node_name 'workflow'
  client_key '/etc/opscode/users/workflow.pem'
  EOS
end

if tagged?('kitchen')
  file '/tmp/config/validation.pem' do
    content lazy { ::File.read('/etc/opscode/orgs/infrastructure-validation.pem') }
  end

  file '/tmp/config/workflow.pem' do
    content lazy { ::File.read('/etc/opscode/users/workflow.pem') }
  end

  file '/tmp/config/builder.pem' do
    content lazy { ::File.read('/etc/opscode/users/builder.pem') }
  end

  file '/tmp/config/supermarket.json' do
    content lazy { ::File.read('/etc/opscode/oc-id-applications/supermarket.json') }
  end
end

execute 'Upload Cookbooks' do
  cwd "#{Chef::Config['file_cache_path']}/cookbooks"
  command 'knife cookbook upload -a --freeze --cookbook-path .'
  only_if { Chef::Config['chef_server_url'].start_with?('chefzero') }
  notifies :register, "chef_client[#{node['fqdn']}]", :immediately
end
