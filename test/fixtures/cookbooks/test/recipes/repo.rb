# Chef Server Core
chef_server_ingredient 'chef-server-core' do
  version node['test']['chef-server-core']['version']
  action :install
end

file '/tmp/chef-server-core.firstrun' do
  content 'ilovechef\n'
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
  action :create
end

# Management Console
chef_server_ingredient 'opscode-manage' do
  action :install
end

file '/tmp/opscode-manage.firstrun' do
  content 'ilovechef\n'
  notifies :reconfigure, 'chef_server_ingredient[opscode-manage]'
  action :create
end
