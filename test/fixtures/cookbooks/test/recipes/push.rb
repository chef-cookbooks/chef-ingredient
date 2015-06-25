chef_ingredient 'push-client' do
  version node['test']['push-client']['version']
  action :install
end
