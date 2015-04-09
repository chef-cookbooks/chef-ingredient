# helper methods for recipe clariy

# TODO: create yum-chef and apt-chef cookbooks and move these
# locations to node attributes. see yum-epel, yum-centos, etc for examples.
def source_url
  case node['platform_family']
  when 'debian'
    if node['platform_version'].to_f == 14.04
      'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.0.5-1_amd64.deb'
    elsif node['platform_version'].to_f == 12.04
      'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.0.5-1_amd64.deb'
    elsif node['platform_version'].to_f == 10.04
      'https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/lucid/chef-server-core_12.0.5-1_amd64.deb'
    end
  when 'rhel'
    if node['platform_version'].to_i == 6
      'https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.5-1.el6.x86_64.rpm'
    elsif node['platform_version'].to_i == 5
      'https://web-dl.packagecloud.io/chef/stable/packages/el/5/chef-server-core-12.0.5-1.el5.x86_64.rpm'
    end
  end
end

def pkgname
  ::File.basename(source_url)
end

def cache_path
  Chef::Config[:file_cache_path]
end

# recipe
remote_file "#{cache_path}/#{pkgname}" do
  source "#{source_url}"
  mode '0644'
end

chef_server_ingredient 'chef-server-core' do
  package_source "#{cache_path}/#{pkgname}"
  action [:install]
end

file '/tmp/chef-server-core.firstrun' do
  content 'ilovechef\n'
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
  action :create
end
