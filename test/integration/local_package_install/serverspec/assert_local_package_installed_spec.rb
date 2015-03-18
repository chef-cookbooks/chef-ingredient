require 'spec_helper'

describe 'chef-server-ingredient::default' do
  describe package('chef-server-core') do
    it { should be_installed }
  end

  describe command('chef-server-ctl test') do
    its(:exit_status) { should eq 0 }
  end
end
