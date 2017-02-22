default['test']['source_url'] = case node['platform_family']
                                when 'debian'
                                  "https://packages.chef.io/stable/ubuntu/#{node['platform_version']}/chef-server-core_12.8.0-1_amd64.deb"
                                when 'rhel'
                                  "https://packages.chef.io/stable/el/#{node['platform_version'].to_i}/chef-server-core-12.8.0-1.el#{node['platform_version'].to_i}.x86_64.rpm"
                                end
