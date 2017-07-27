#
# This recipe tests the :unstable channel.
# This channel is only accessible from Chef's internal
# network and contains untested builds of Chef products.
#
# Make sure you set below environment variables for
# tests to work correctly.
#

include_recipe 'test::install_git'

chef_ingredient 'compliance' do
  action :install
  channel :stable
  version :latest
end

chef_ingredient 'compliance' do
  action :upgrade
  channel :unstable
  version :latest
end
