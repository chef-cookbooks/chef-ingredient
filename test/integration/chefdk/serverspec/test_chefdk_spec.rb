require 'spec_helper'

describe 'test::chefdk' do
  it 'chefdk should be version 0.8.0' do
    command = if os[:family] == 'windows'
                `C:\\opscode\\chefdk\\bin\\chef --version`
              else
                `/opt/chefdk/bin/chef --version`
              end

    expect(command).to include('Chef Development Kit Version: 0.8.0')
  end
end
