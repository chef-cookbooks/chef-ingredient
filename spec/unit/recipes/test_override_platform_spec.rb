require 'spec_helper'

describe 'test::override_platform' do
  context 'install chefdk on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'installs chefdk' do
      expect(ubuntu_1404).to install_chef_ingredient('chefdk').with(platform: 'el', platform_version: '5')
    end
  end
end
