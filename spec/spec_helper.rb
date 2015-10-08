require 'chefspec'
require 'chefspec/berkshelf'

# Requires https://github.com/sethvargo/chefspec/commit/cd57e28fdbd59fc26962c0dd3b1809b8841312f3
# require 'chefspec/policyfile'

TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SUPPORT_DIR = File.join(TOPDIR, 'spec', 'support')
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

at_exit { ChefSpec::Coverage.report! }
