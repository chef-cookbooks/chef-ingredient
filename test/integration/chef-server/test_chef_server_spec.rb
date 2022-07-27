# describe command('chef-server-ctl test') do
#   its('exit_status') { should eq 0 }
# end

describe command('chef-server-ctl status opscode-erchef') do
  its('stdout') { should match(/run: opscode-erchef:/) }
end
