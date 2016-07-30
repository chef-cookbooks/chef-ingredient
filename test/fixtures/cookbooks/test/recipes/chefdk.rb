chef_ingredient 'chefdk' do
  action :install
  channel :stable
  version '0.15.16'
end

chef_ingredient 'chefdk' do
  action :upgrade
  channel :stable
  version '0.16.28'
end
