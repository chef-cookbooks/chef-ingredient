apt_update 'update' if node['platform_family'] == 'debian'

include_recipe 'git'
