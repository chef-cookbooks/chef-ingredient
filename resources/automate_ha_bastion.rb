#
# Cookbook:: chef-ingredient
# Resource:: automate_standalone
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

provides :chef_automate_ha_default
resource_name :chef_automate_ha_bastion

unified_mode true if respond_to?(:unified_mode)

property :channel, Symbol, default: :current
property :version, [String, Symbol], default: :latest
property :config, String, required: true
property :accept_license, [true, false], default: false
property :products, Array, default: ['automate']

action :install do

  # Create common user for all nodes
  user_name = node['automate_ha']['username']

  user user_name

  # Create Authorized Keys entries
  node['automate_ha']['ssh_authorize_key']&.each do |name, hash|
    ssh_authorize_key name do
      hash&.each do |key, value|
        send(key, value)
      end
    end
  end

  # Ensure user has sudo permissions without password
  sudo node['automate_ha']['username'] do
    nopasswd true
    users node['automate_ha']['username']
  end

  # Create /etc/hosts file entries if not using DNS
  unless node['automate_ha']['dns_configured']
    replace_or_add 'automate' do
      path '/etc/hosts'
      pattern ".* #{node['automate_ha']['automate_dns_entry']}"
      line "#{node['automate_ha']['instance_ips']['automate_frontend'].first} #{node['automate_ha']['automate_dns_entry']}"
      remove_duplicates true
    end

    replace_or_add 'infra-server' do
      path '/etc/hosts'
      pattern ".* #{node['automate_ha']['infra-server_dns_entry']}"
      line "#{node['automate_ha']['instance_ips']['chef_frontend'].first} #{node['automate_ha']['infra-server_dns_entry']}"
      remove_duplicates true
    end
  end

  # Set SElinux to permissive mode
  selinux_state 'default' do
    automatic_reboot true
    action :permissive
  end
end

action :uninstall do

end
