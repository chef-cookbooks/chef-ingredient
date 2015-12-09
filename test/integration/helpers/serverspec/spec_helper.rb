require 'serverspec'

if !(RUBY_PLATFORM !~ /mswin|mingw|windows/)
  set :backend, :winrm
else
  set :backend, :exec
end
