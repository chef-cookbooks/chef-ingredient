require 'spec_helper'

describe 'test::chefdk' do
  it 'chefdk should be version 0.7.0' do
    command = `/opt/chefdk/bin/chef --version`
    expect(command).to include('Chef Development Kit Version: 0.7.0')
  end
end
