chef_ingredient 'install old chefdk version' do
  product_name 'chefdk'
  action :install
  version '1.5.0'
  platform_version_compatibility_mode true
end

chef_ingredient 'upgrade to newer chefdk version' do
  product_name 'chefdk'
  action :upgrade
  version '2.0.28'
  platform_version_compatibility_mode true
end
