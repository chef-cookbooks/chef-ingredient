# describe command('chef-server-ctl test') do
#   its('exit_status') { should eq 0 }
# end

describe command('chef-automate version') do
  its('exit_status') { should eq 0 }
end

%w(80 443).each do |port|
  describe port(port) do
    it { should be_listening }
  end
end
