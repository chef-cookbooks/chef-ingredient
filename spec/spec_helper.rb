require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../libraries/default_handler'
require_relative '../libraries/omnitruck_handler'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
  config.log_level = :error

  config.before do
    artifact_info = instance_double('artifact info',
      url: 'http://packages.chef.io',
      sha256: 'f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b')
    installer = instance_double('installer',
      artifact_info: artifact_info,
      current_version: nil,
      install_command: 'install_command')
    allow_any_instance_of(ChefIngredient::DefaultHandler).to receive(:installer).and_return(installer)
    allow_any_instance_of(ChefIngredient::OmnitruckHandler).to receive(:installer).and_return(installer)
  end
end
