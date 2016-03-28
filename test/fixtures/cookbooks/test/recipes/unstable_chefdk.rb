#
# This recipe tests the :unstable channel.
# This channel is only accessible from Chef's internal
# network and contains untested builds of Chef products.
#
# Make sure you set below environment variables for
# tests to work correctly.
#

include_recipe 'apt'
include_recipe 'yum'
include_recipe 'git'

chef_ingredient 'chefdk' do
  action :upgrade
  channel :unstable
  version :latest
  artifactory_username node['artifactory']['username']
  artifactory_password node['artifactory']['password']
end
