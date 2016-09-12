require 'chefspec'
require 'chefspec/berkshelf'

require_relative '../libraries/chef_ingredient_provider'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM

  config.before(:each) do
    artifact_info = instance_double('artifact info',
      url: 'http://packages.chef.io',
      sha256: 'f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b')
    installer = instance_double('installer', artifact_info: artifact_info)
    allow_any_instance_of(Chef::Provider::ChefIngredient).to receive(:installer).and_return(installer)
  end
end
