case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum'
end

include_recipe 'git'
