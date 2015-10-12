require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
  config.log_level = :error
end

TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SUPPORT_DIR = File.join(TOPDIR, 'spec', 'support')
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

at_exit { ChefSpec::Coverage.report! }
