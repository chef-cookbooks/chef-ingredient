chef_ingredient 'chef-server'

chef_ingredient 'chef-server' do
  action :upgrade
  channel :current
end
