# This test recipe is used within test kitchen to perform additional
# setup, or to configure custom resources in the main cookbook.

# For example, update the apt cache on Debian systems, which avoids
# requiring the `apt` cookbook. This doesn't work, of course, if the
# apt cache must be updated before the main cookbook's default recipe
# is run.
execute 'apt-get update' if platform_family?('debian')

remote_file '/etc/pki/tls/certs/ca-bundle.crt' do
  source 'http://opscode-omnibus-cache.s3.amazonaws.com/cacerts-2014.07.15-fd48275847fa10a8007008379ee902f1'
  checksum 'a9cce49cec92304d29d05794c9b576899d8a285659b3f987dd7ed784ab3e0621'
  sensitive true
end if platform_family?('rhel')

source_url =
if platform_family?('debian')
  if node[:platform_version].eql?('14.04')
    "https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.0.5-1_amd64.deb"
  elsif node[:platform_version].eql?('12.04')
    "https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.0.5-1_amd64.deb"
  elsif node[:platform_version].eql?('10.04')
    "https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/lucid/chef-server-core_12.0.5-1_amd64.deb"
  end
elsif platform_family?('rhel')
  if node[:platform_version].eql?('6.6')
    "https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.5-1.el6.x86_64.rpm"
  elsif node[:platform_version].eql?('5.11')
    "https://web-dl.packagecloud.io/chef/stable/packages/el/5/chef-server-core-12.0.5-1.el5.x86_64.rpm"
  end
end

package = File.basename(source_url)  
remote_file "#{Chef::Config[:file_cache_path]}/#{package}" do
  source    "#{source_url}"
  mode      "0644"
end
  
chef_server_ingredient 'chef-server-core' do
  package_path "#{Chef::Config[:file_cache_path]}/#{package}"
  action [:install, :reconfigure]
end