describe 'test::chefdk' do
  it 'chefdk should print a version' do
    command = if os.windows?
                `C:\\opscode\\chefdk\\bin\\chef --version`
              else
                `/opt/chefdk/bin/chef --version`
              end

    expect(command).to include('Chef Development Kit Version:')
  end
end
