#
# Cookbook:: chef-ingredient
# Resource:: automatev2
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

provides :chef_automatev2
resource_name :chef_automatev2

unified_mode true if respond_to?(:unified_mode)

property :channel, Symbol, default: :current
property :version, [String, Symbol], default: :latest
property :config, String, required: true
property :accept_license, [true, false], default: false
property :products, Array, default: ['automate']
property :skip_verify, [TrueClass, FalseClass], default: false

action :create do
  bin_path = value_for_platform_family(
    debian: '/bin/chef-automate',
    default: '/usr/bin/chef-automate'
  )

  execute "curl https://packages.chef.io/files/#{new_resource.channel}/#{new_resource.version}/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate" do
    cwd '/usr/local/bin'
    creates '/usr/local/bin/chef-automate'
    not_if { FileTest.file?(bin_path) }
  end

  sysctl 'vm.max_map_count' do
    value 262144
  end

  sysctl 'vm.dirty_expire_centisecs' do
    value 20000
  end

  execute '/usr/local/bin/chef-automate init-config' do
    cwd Chef::Config[:file_cache_path]
    creates "#{Chef::Config[:file_cache_path]}/config.toml"
    only_if { FileTest.file?('/usr/local/bin/chef-automate') }
  end

  execute "/usr/local/bin/chef-automate deploy #{Chef::Config[:file_cache_path]}/config.toml#{' --skip-verify' if new_resource.skip_verify} --product #{new_resource.products.join(' --product ')}#{' --accept-terms-and-mlsa' if new_resource.accept_license}" do
    cwd Chef::Config[:file_cache_path]
    live_stream true
    only_if { FileTest.file?("#{Chef::Config[:file_cache_path]}/config.toml") }
    not_if { FileTest.file?(bin_path) && shell_out("#{bin_path} service-versions").exitstatus.eql?(0) }
  end

  file "#{Chef::Config[:file_cache_path]}/custom_config.toml" do
    content new_resource.config
    notifies :run, "execute[chef-automate config patch #{Chef::Config[:file_cache_path]}/custom_config.toml]", :immediately
  end

  execute "chef-automate config patch #{Chef::Config[:file_cache_path]}/custom_config.toml" do
    cwd Chef::Config[:file_cache_path]
    live_stream true
    action :nothing
    only_if { FileTest.file?(bin_path) }
  end

  file '/usr/local/bin/chef-automate' do
    action :delete
  end
end

action :uninstall do
  execute 'chef-automate uninstall --yes'
end

action :reconfigure do
  bin_path = value_for_platform_family(
    debian: '/bin/chef-automate',
    default: '/usr/bin/chef-automate'
  )

  file "#{Chef::Config[:file_cache_path]}/custom_config.toml" do
    content new_resource.config
    notifies :run, "execute[chef-automate config patch #{Chef::Config[:file_cache_path]}/custom_config.toml]", :immediately
  end

  execute "chef-automate config patch #{Chef::Config[:file_cache_path]}/custom_config.toml" do
    cwd Chef::Config[:file_cache_path]
    live_stream true
    action :nothing
    only_if { FileTest.file?(bin_path) }
  end
end
