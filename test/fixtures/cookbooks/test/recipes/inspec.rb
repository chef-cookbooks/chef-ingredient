chef_ingredient 'install old inspec version' do
  product_name 'inspec'
  version '1.30.0'
  platform_version_compatibility_mode true
end

chef_ingredient 'upgrade to newer inspec version' do
  product_name 'inspec'
  action :upgrade
  version '1.31.1'
  platform_version_compatibility_mode true
end
