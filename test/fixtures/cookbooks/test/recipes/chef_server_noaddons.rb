node.default['chef_server']['fqdn'] = 'localhost'

chef_server node['chef_server']['fqdn'] do
  config <<-EOS
api_fqdn '#{node['chef_server']['fqdn']}'
  EOS
  accept_license true
end
