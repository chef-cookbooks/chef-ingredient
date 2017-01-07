#
# Cookbook Name:: chef_stack
# Recipe:: _kitchen
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

Chef::Log.warn('This recipe is designed for local development only.  It should not be run outside of kitchen.')

tag('kitchen')

hosts = Chef::Util::FileEdit.new('/etc/hosts')
hosts.insert_line_if_no_match(/chef.local/, '192.168.254.10 chef.local chef chef-centos-72')
hosts.insert_line_if_no_match(/automate.local/, '192.168.254.20 automate.local automate automate-centos-72')
hosts.insert_line_if_no_match(/buildv1.local/, '192.168.254.21 buildv1.local buildv1 buildv1-centos-72')
hosts.insert_line_if_no_match(/buildv2.local/, '192.168.254.22 buildv2.local buildv2 buildv2-centos-72')
hosts.insert_line_if_no_match(/supermarket.local/, '192.168.254.30 supermarket.local supermarket supermarket-centos-72')
hosts.insert_line_if_no_match(/compliance.local/, '192.168.254.31 compliance.local compliance compliance-centos-72')
hosts.write_file

# execute 'upload cookbooks' do
#   command 'knife cookbook upload --cookbook-path ../ --freeze chef'
# end

log 'run chef-client for kitchen' do
  notifies :run, "chef_client[#{node['fqdn']}]", :delayed
end
