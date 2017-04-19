resource_command = os.windows? ? 'powershell' : 'command'

describe send(resource_command, 'chef --version') do
  its('stdout') { should match /Chef Development Kit Version: 1.2.22/ }
end
