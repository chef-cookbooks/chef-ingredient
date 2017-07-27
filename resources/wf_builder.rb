#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: wf_runner
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

resource_name 'workflow_builder'
default_action :create

property :name, String, name_property: true
property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :pj_version, [String, Symbol], default: :latest
property :accept_license, [TrueClass, FalseClass], default: false
property :chef_user, String, default: 'workflow'
property :chef_user_pem, String, required: true
property :builder_pem, String, required: true
property :chef_fqdn, String, default: URI.parse(Chef::Config['chef_server_url']).host
property :automate_fqdn, String, required: true
property :supermarket_fqdn, String
property :job_dispatch_version, String, default: 'v2'
property :automate_user, String, default: 'admin'
property :automate_password, String
property :automate_enterprise, String, default: 'chef'
property :chef_config_path, String, default: '/etc/chef/client.rb'
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  chef_ingredient 'chefdk' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  directory '/etc/chef/trusted_certs' do
    recursive true
    mode '0755'
  end

  [
    new_resource.chef_fqdn,
    new_resource.automate_fqdn,
    new_resource.supermarket_fqdn,
  ].each do |server|
    execute "fetch ssl cert for #{server}" do
      command "knife ssl fetch -s https://#{server} -c #{Chef::Config['config_file']}"
      not_if "knife ssl check -s https://#{server} -c #{Chef::Config['config_file']}"
      ignore_failure true
    end
  end

  execute 'cat /etc/chef/trusted_certs/*.crt >> /opt/chefdk/embedded/ssl/certs/cacert.pem'

  ohai 'reload_passwd' do
    action :nothing
    plugin 'etc'
    ignore_failure true
  end

  workspace = '/var/opt/delivery/workspace'

  group 'dbuild'

  user 'dbuild' do
    home workspace
    group 'dbuild'
    notifies :reload, 'ohai[reload_passwd]', :immediately
  end

  %w(.chef bin lib etc).each do |dir|
    directory "#{workspace}/#{dir}" do
      mode '0755'
      owner 'dbuild'
      group 'dbuild'
      recursive true
    end
  end

  %w(etc .chef).each do |dir|
    chef_file "#{workspace}/#{dir}/builder_key" do
      source new_resource.builder_pem
      mode '0600'
      user 'root'
      group 'root'
    end

    chef_file "#{workspace}/#{dir}/#{chef_user}.pem" do
      source new_resource.chef_user_pem
      mode '0600'
      user 'root'
      group 'root'
    end
  end

  %w(etc/delivery.rb .chef/knife.rb).each do |dir|
    file "#{workspace}/#{dir}" do
      content ensurekv(::File.read(new_resource.chef_config_path),
                       node_name: new_resource.chef_user,
                       log_location: :STDOUT,
                       client_key: "#{workspace}/#{dir}/#{new_resource.chef_user}.pem",
                       trusted_certs_dir: '/etc/chef/trusted_certs')
      mode '0644'
      owner 'dbuild'
      group 'dbuild'
    end
  end

  remote_file "#{workspace}/bin/git_ssh" do
    source "https://#{automate_fqdn}/installer/git-ssh-wrapper"
    owner 'dbuild'
    group 'dbuild'
    mode '0755'
  end

  remote_file "#{workspace}/bin/delivery-cmd" do
    source "https://#{automate_fqdn}/installer/delivery-cmd"
    owner 'root'
    group 'root'
    mode '0750'
  end

  file '/etc/chef/client.pem' do
    owner 'root'
    group 'dbuild'
    mode '0640'
  end

  file new_resource.chef_config_path do
    mode '0644'
  end

  Dir.glob('/etc/chef/trusted_certs/*').each do |fn|
    file fn do
      mode '0644'
    end
  end

  case new_resource.job_dispatch_version
  when 'v1'
    execute 'tag node as legacy build-node' do
      command "knife tag create #{Chef::Config['node_name']} delivery-build-node -c new_resource.chef_config_path"
      not_if { node['tags'].include?('delivery-build-node') }
    end

    directory '/var/log/push-jobs-client' do
      recursive true
    end

    chef_ingredient 'push-jobs-client' do
      version new_resource.pj_version
    end

    template '/etc/chef/push-jobs-client.rb' do
      source 'push-jobs-client.rb.erb'
      notifies :restart, 'service[push-jobs-client]', :delayed
    end

    if node['init_package'].eql?('systemd')
      init_template = 'push-jobs-client-systemd'
      init_file = '/etc/systemd/system/push-jobs-client.service'
    elsif node['platform_family'].eql?('debian')
      init_template = 'push-jobs-client-ubuntu-upstart'
      init_file = '/etc/init/push-jobs-client.conf'
    elsif node['platform_family'].eql?('rhel')
      init_template = 'push-jobs-client-rhel-6'
      init_file = '/etc/rc.d/init.d/push-jobs-client'
    else
      raise 'Unsupported platform for build node'
    end

    remote_file init_file do
      source "https://#{automate_fqdn}/installer/#{init_template}"
      mode '0755'
      notifies :restart, 'service[push-jobs-client]', :delayed
    end

    service 'push-jobs-client' do
      action [:enable, :start]
    end
  when 'v2'
    build_user = 'job_runner'
    home_dir = '/home/job_runner'

    execute 'tag node as job-runner' do
      command "knife tag create #{Chef::Config['node_name']} delivery-job-runner -c #{new_resource.chef_config_path}"
      not_if { node['tags'].include?('delivery-job-runner') }
    end

    user build_user do
      action [:create, :lock]
      home home_dir
    end

    directory home_dir do
      owner build_user
      group build_user
    end

    directory "#{home_dir}/.ssh" do
      owner build_user
      group build_user
      notifies :touch, "file[#{home_dir}/.ssh/authorized_keys]", :immediately
    end

    file "#{home_dir}/.ssh/authorized_keys" do
      action :nothing
    end

    # TODO: Figure out how to auto-detect enterprise
    ruby_block 'install job runner' do # ~FC014
      block do
        ENV['AUTOMATE_PASSWORD'] = new_resource.automate_password

        Mixlib::ShellOut.new("delivery token \
        -s #{new_resource.automate_fqdn} \
        -e #{new_resource.automate_enterprise} \
        -u #{new_resource.automate_user}").run_command

        data = {
          hostname: new_resource.name,
          os: node['os'],
          platform_family: node['platform_family'],
          platform: node['platform'],
          platform_version: node['platform_version'],
        }

        runner = Mixlib::ShellOut.new("delivery api post runners \
          -d '#{data.to_json}' \
          -s #{new_resource.automate_fqdn} \
          -e #{new_resource.automate_enterprise} \
          -u #{new_resource.automate_user}").run_command
        ::File.write(::File.join(home_dir, '.ssh/authorized_keys'), JSON.parse(runner.stdout)['openssh_public_key'])
      end
      not_if { ::File.read(::File.join(home_dir, '.ssh/authorized_keys')).include?("#{build_user}@#{node['fqdn']}") }
    end

    file ::File.join('/etc/sudoers.d', build_user) do
      content <<-EOF
    #{build_user} ALL=(root) NOPASSWD:/usr/local/bin/delivery-cmd, /bin/ls
    Defaults:#{build_user} !requiretty
    Defaults:#{build_user} secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    EOF
      mode '0440'
    end

    directory ::File.join(home_dir, '.ssh') do
      owner build_user
      group build_user
      mode '0700'
    end

    file ::File.join(home_dir, '.ssh/authorized_keys') do
      owner build_user
      group build_user
      mode '0600'
    end

    file '/usr/local/bin/delivery-cmd' do
      content lazy { ::File.read('/var/opt/delivery/workspace/bin/delivery-cmd') }
      owner 'dbuild'
      group 'dbuild'
      mode '0755'
    end
  else
    raise 'Invalid Runner Version'
  end
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
