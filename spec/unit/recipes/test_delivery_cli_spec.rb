require 'spec_helper'

describe 'test::delivery_cli' do
  context 'installs delivery-cli on ubuntu 15.04' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '15.04',
        step_into: ['chef_ingredient']
      ).converge(described_recipe)
    end

    it 'installs the chef_ingredient[push-client]' do
      expect(chef_run).to install_chef_ingredient('delivery-cli').with(platform_version_compatibility_mode: true)
    end
  end
end
