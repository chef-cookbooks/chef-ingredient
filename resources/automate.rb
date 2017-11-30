#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: automate
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

resource_name 'chef_automate'
default_action :create

property :fqdn, String, name_property: true
property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :config, String, required: true
property :accept_license, [TrueClass, FalseClass], default: false
property :enterprise, [String, Array], default: 'chef'
property :license, String
property :chef_user, String, default: 'workflow'
property :chef_user_pem, String, required: true
property :chef_server, String, required: true
property :validation_pem, String, required: true
property :builder_pem, String, required: true
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # node.run_state['chef-orgs'] ||= Mixlib::ShellOut.new('chef-server-ctl org-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-orgs'].index(/^#{org}$/)
end

action :create do
  required_config = <<-EOF
    delivery['chef_username'] = '#{new_resource.chef_user}'
    delivery['chef_private_key'] = '/etc/delivery/#{new_resource.chef_user}.pem'
    delivery['chef_server'] = '#{new_resource.chef_server}'
    delivery['default_search'] = 'tags:delivery-build-node'
  EOF

  chef_ingredient 'automate' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    config ensurekv(new_resource.config.dup.concat(required_config), delivery_fqdn: new_resource.fqdn)
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
    sensitive new_resource.sensitive if new_resource.sensitive
  end

  # Extract custom username and group from the automate config, if it is set.
  # We will use these values to set permissions on files appropriately.
  os_user = new_resource.config[/user\['username'\] ?= ?['"](?<username>.*)['"]/, 'username'] || 'delivery'
  os_group = new_resource.config[/user\['group'\] ?= ?['"](?<group>.*)['"]/, 'group'] || 'delivery'

  %w(/etc/delivery /etc/chef /var/opt/delivery/license).each do |dir|
    directory dir do
      recursive true
    end
  end

  chef_file '/var/opt/delivery/license/delivery.license' do
    sensitive new_resource.sensitive if new_resource.sensitive
    source new_resource.license
    user os_user
    group os_group
    mode '0644'
  end

  {
    "/etc/delivery/#{new_resource.chef_user}.pem" => new_resource.chef_user_pem,
    '/etc/chef/validation.pem' => new_resource.validation_pem,
  }.each do |file, src|
    chef_file file do
      sensitive new_resource.sensitive if new_resource.sensitive
      source src
      user 'root'
      group 'root'
      mode '0644'
    end
  end

  chef_file '/etc/delivery/builder_key' do
    sensitive new_resource.sensitive if new_resource.sensitive
    source new_resource.builder_pem
    user 'root'
    group 'root'
    mode '0600'
  end

  file '/etc/delivery/builder_key.pub' do
    sensitive new_resource.sensitive if new_resource.sensitive
    content lazy { "ssh-rsa #{[OpenSSL::PKey::RSA.new(::File.read('/etc/delivery/builder_key')).to_blob].pack('m0')}" }
    user 'root'
    group 'root'
    mode '0644'
  end

  directory '/var/opt/delivery/nginx/etc/addon.d' do
    recursive true
  end

  file '/var/opt/delivery/nginx/etc/addon.d/99-installer_internal.conf' do
    content <<-EOF
location /installer {
  alias /opt/delivery/embedded/service/omnibus-ctl/installer;
}
EOF
  end

  ingredient_config 'automate' do
    notifies :reconfigure, 'chef_ingredient[automate]', :immediately
  end

  Array(new_resource.enterprise).each do |ent|
    execute "create enterprise #{ent}" do
      command "automate-ctl create-enterprise #{ent} --ssh-pub-key-file=/etc/delivery/builder_key.pub >> /etc/delivery/#{ent}.creds"
      not_if "automate-ctl list-enterprises --ssh-pub-key-file=/etc/delivery/builder_key.pub | grep -w #{ent}"
      only_if 'automate-ctl status'
    end
  end
end

action_class do
  include ChefIngredientCookbook::Helpers
end
