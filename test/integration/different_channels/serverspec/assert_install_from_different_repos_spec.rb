require 'spec_helper'

describe 'chef-ingredient::default' do
  it 'chef-server-core should be installed from stable' do
    # This version is only available in stable
    expect(package('chef-server-core').version).to eq('12.2.0-1')
  end

  it 'opscode-analytics should be installed from current' do
    # This version is only available in current
    expect(package('opscode-analytics').version).to eq('1.1.6+20150918090908.git.49.337923e-1')
  end
end
