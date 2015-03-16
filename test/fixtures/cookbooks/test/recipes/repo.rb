chef_server_ingredient 'chef-server-core' do
  action [:install, :reconfigure]
  version node['test']['chef-server-core']['version']
end

chef_server_ingredient 'opscode-manage' do
  action [:install, :reconfigure]
end
