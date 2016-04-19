# Chef Server Core
chef_ingredient 'chef-server' do
  version node['test']['chef-server-core']['version']
  config <<-EOS
api_fqdn "#{node['fqdn']}"
ip_version "ipv6"
notification_email "#{node['chef_admin']}"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
  action :reconfigure
end

# Management Console - using the compat shim resource
chef_server_ingredient 'manage' do
  accept_license true
  action :reconfigure
end
