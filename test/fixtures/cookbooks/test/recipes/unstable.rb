#
# This recipe tests the :unstable channel.
# This channel is only accessible from Chef's internal
# network and contains untested builds of Chef products.
#
# Make sure you set below environment variables for
# tests to work correctly.
#

env 'ARTIFACTORY_USERNAME' do
  value 'username@chef.io'
end

env 'ARTIFACTORY_PASSWORD' do
  value 'XXXXXXXXXXXXX'
end

chef_ingredient 'chef' do
  action :upgrade
  channel :unstable
  version :latest
end
