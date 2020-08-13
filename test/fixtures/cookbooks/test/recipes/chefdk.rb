chef_ingredient 'install old chefdk version' do
  product_name 'chefdk'
  action :install
  version '3.13.1'
  platform_version_compatibility_mode true
end

chef_ingredient 'upgrade to newer chefdk version' do
  product_name 'chefdk'
  action :upgrade
  version '4.10.0'
  platform_version_compatibility_mode true
end
