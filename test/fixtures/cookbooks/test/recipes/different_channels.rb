chef_ingredient 'chef-server' do
  channel :stable
  version '12.2.0' # only available in stable
  action :install
end

chef_ingredient 'analytics' do
  channel :current
  version '1.1.6+20150918090908.git.49.337923e' # only available in current
  action :install
end
