require 'chefspec'

# Requires https://github.com/sethvargo/chefspec/commit/cd57e28fdbd59fc26962c0dd3b1809b8841312f3
require 'chefspec/policyfile'

at_exit { ChefSpec::Coverage.report! }
