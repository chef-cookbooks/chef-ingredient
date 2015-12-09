# Configure a custom repository setup recipe
node.set['chef-ingredient']['custom_repo_setup_recipe'] = 'my_awesome::repo_recipe'

chef_ingredient 'chef-server' do
  action :install
end
