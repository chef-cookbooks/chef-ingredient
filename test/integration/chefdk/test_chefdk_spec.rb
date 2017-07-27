# The way this spec is written is more of an experiment. Executing Windows programs for the first time
# via inspec require the fully qualified path. Even though the bin has been added to $env:Path the session
# has not been reloaded. This reloads $env:Path before calling the program. I could see this being beneficial to
# inspec's default behavior.

resource_command = 'command'

if os.windows?
  resource_command = 'powershell'

  describe powershell('$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")') do
    its('exit_status') { should eq 0 }
  end
end

describe send(resource_command, 'chef --version') do
  its('stdout') { should match(/Chef Development Kit Version: 2.0.28/) }
end
