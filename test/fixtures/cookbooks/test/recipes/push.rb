chef_ingredient 'push-jobs-client' do
  version node['test']['push-client']['version']
  action :install
end
