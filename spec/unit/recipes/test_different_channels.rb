require 'spec_helper'

describe 'test::different_channels' do
  context 'different channels on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'sets up stable apt repository' do
      expect(ubuntu_1404).to add_apt_repository('chef-stable')
    end

    it 'pins future installs of chef-server to stable repository' do
      expect(ubuntu_1404).to add_apt_preference('chef-server-core').with(pin: 'release o=https://packagecloud.io/chef/stable',
                                                                         pin_priority: '900')
    end

    it 'installs chef-server' do
      expect(ubuntu_1404).to install_package('chef-server-core')
    end

    it 'sets up current apt repository' do
      expect(ubuntu_1404).to add_apt_repository('chef-current')
    end

    it 'pins future installs of analytics to current repository' do
      expect(ubuntu_1404).to add_apt_preference('opscode-analytics').with(pin: 'release o=https://packagecloud.io/chef/current',
                                                                          pin_priority: '900')
    end

    it 'installs analytics' do
      expect(ubuntu_1404).to install_package('opscode-analytics')
    end
  end
end
