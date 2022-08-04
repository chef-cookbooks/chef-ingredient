# describe command('chef-server-ctl test') do
#   its('exit_status') { should eq 0 }
# end

describe file('/usr/local/bin/chef-automate') do
  it { should_not exist }
end

bin_path = if os.debian?
             '/bin/chef-automate'
           else
             '/usr/bin/chef-automate'
           end

describe file(bin_path) do
  it { should exist }
end

describe command('chef-automate version') do
  its('exit_status') { should eq 0 }
end

%w(80 443).each do |port|
  describe port(port) do
    it { should be_listening }
  end
end
