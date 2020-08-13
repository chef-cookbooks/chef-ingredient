name 'chef-ingredient'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Primitives for managing Chef products and packages'
version '3.2.0'

%w(amazon centos redhat scientific oracle fedora debian ubuntu).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/chef-ingredient'
issues_url 'https://github.com/chef-cookbooks/chef-ingredient/issues'

chef_version '>= 13.0'
