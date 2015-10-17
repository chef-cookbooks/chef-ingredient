require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
  config.log_level = :error
end

at_exit { ChefSpec::Coverage.report! }
