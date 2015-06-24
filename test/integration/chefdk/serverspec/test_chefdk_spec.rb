require 'spec_helper'

describe 'test::chefdk' do
  describe package('chefdk') do
    it { should be_installed }
  end
end
