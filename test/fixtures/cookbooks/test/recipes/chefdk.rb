chef_ingredient 'chefdk' do
  action :install
  channel :stable
  version '0.5.1'
end

chef_ingredient 'chefdk' do
  action :upgrade
  channel :stable
  version '0.7.0'
end
