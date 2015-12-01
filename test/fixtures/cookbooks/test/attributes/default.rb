default['test']['push-client']['version'] = nil
default['test']['chef-server-core']['version'] = nil
default['test']['source_url'] = case node['platform_family']
                                when 'debian'
                                  if node['platform_version'].to_f == 14.04
                                    'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.3.1-1_amd64.deb'
                                  elsif node['platform_version'].to_f == 12.04
                                    'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.3.1-1_amd64.deb'
                                  elsif node['platform_version'].to_f == 10.04
                                    'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/lucid/chef-server-core_12.3.1-1_amd64.deb'
                                  end
                                when 'rhel'
                                  if node['platform_version'].to_i == 6
                                    'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.3.1-1.el6.x86_64.rpm'
                                  elsif node['platform_version'].to_i == 7
                                    'https://web-dl.packagecloud.io/chef/stable/packages/el/7/chef-server-core-12.3.1-1.el7.x86_64.rpm'
                                  end
                                end
