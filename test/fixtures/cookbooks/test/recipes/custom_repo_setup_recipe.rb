# Configure a custom repository setup recipe
node.normal['chef-ingredient']['custom-repo-recipe'] = 'custom_repo::awesome_custom_setup'

chef_ingredient 'chef-server' do
  action :install
end
