#
# This recipe tests the :unstable channel.
# This channel is only accessible from Chef's internal
# network and contains untested builds of Chef products.
#
# Make sure you set below environment variables for
# tests to work correctly.
#

ENV['ARTIFACTORY_USERNAME'] = node['artifactory']['username']
ENV['ARTIFACTORY_PASSWORD'] = node['artifactory']['password']

chef_ingredient 'chef-server' do
  action :install
  channel :unstable
  version :latest
end
