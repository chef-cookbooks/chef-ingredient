chef_ingredient 'install old chefdk version' do
  product_name 'chefdk'
  action :install
  version '1.1.16'
end

chef_ingredient 'upgrade to newer chefdk version' do
  product_name 'chefdk'
  action :upgrade
  version '1.2.22'
end
