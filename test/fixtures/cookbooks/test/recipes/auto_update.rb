# auto update chef on the box to the latest build in the current channel.

node.default['apt-chef']['repo_name'] = 'chef-current'

chef_ingredient 'chef' do
  action :upgrade
end
