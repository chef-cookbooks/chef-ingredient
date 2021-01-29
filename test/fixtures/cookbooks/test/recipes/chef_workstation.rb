chef_ingredient 'install old chef-workstation version' do
  product_name 'chef-workstation'
  action :install
  version '0.18.3'
  platform_version_compatibility_mode true
end

chef_ingredient 'upgrade to newer chef-workstation version' do
  product_name 'chef-workstation'
  action :upgrade
  version '21.1.247'
  platform_version_compatibility_mode true
end
