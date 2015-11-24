# Chef Server Core
chef_ingredient 'chef-server' do
  version node['test']['chef-server-core']['version']
  channel node['test']['chef-server-core']['channel']
  config <<-EOS
api_fqdn "#{node['fqdn']}"
ip_version "ipv6"
notification_email "#{node['chef_admin']}"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
  action :install
end

file '/tmp/chef-server-core.firstrun' do
  content 'ilovechef\n'
  action :create
end

ingredient_config 'chef-server' do
  notifies :reconfigure, 'chef_ingredient[chef-server]'
end

# Management Console - using the compat shim resource
chef_server_ingredient 'manage' do
  config <<-EOS
disable_sign_up true
support_email_address "#{node['chef_admin']}"
EOS
  action :install
end

file '/tmp/opscode-manage.firstrun' do
  content 'ilovechef\n'
  action :create
end

ingredient_config 'manage' do
  notifies :reconfigure, 'chef_server_ingredient[manage]'
  sensitive true
end
