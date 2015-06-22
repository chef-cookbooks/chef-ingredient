# Chef Server Core
chef_ingredient 'chef-server' do
  version node['test']['chef-server-core']['version']
  action :install
end

file '/tmp/chef-server-core.firstrun' do
  content 'ilovechef\n'
  notifies :reconfigure, 'chef_ingredient[chef-server]'
  action :create
end

# Management Console - using the compat shim resource
chef_server_ingredient 'manage' do
  action :install
end

file '/tmp/opscode-manage.firstrun' do
  content 'ilovechef\n'
  notifies :reconfigure, 'chef_server_ingredient[manage]'
  action :create
end
