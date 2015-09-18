require 'spec_helper'

describe 'test::chefdk' do
  describe package('chefdk') do
    it { should be_installed }
  end

  it 'chefdk should be upgraded' do
    expect(package('chefdk').version).to eq('0.7.0-1')
  end
end
