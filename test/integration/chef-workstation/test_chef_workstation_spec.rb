# The way this spec is written is more of an experiment. Executing Windows programs for the first time
# via inspec require the fully qualified path. Even though the bin has been added to $env:Path the session
# has not been reloaded. This reloads $env:Path before calling the program. I could see this being beneficial to
# inspec's default behavior.

describe package('chef-workstation') do
  it { should be_installed }
end
