require 'spec_helper'

describe 'chef-server-ingredient::default' do
  describe package('chef-server-core') do
    it { should be_installed.with_version('12.0.0-rc.5-1') }
  end
end
