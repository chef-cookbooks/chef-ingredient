require 'spec_helper'

describe file('/etc/opscode/chef-server.rb') do
  it { should contain "topology 'torus'" }
end
