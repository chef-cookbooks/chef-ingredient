require 'spec_helper'

describe 'test::chef' do
  context 'install chef on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'sets up current apt repository' do
      expect(ubuntu_1404).to add_apt_repository('chef-current')
    end

    it 'pins future installs of chef to current repository' do
      expect(ubuntu_1404).to add_apt_preference('chef').with(pin: 'release o=https://packagecloud.io/chef/current',
                                                             pin_priority: '900')
    end

    it 'installs chef' do
      expect(ubuntu_1404).to upgrade_package('chef')
    end

    it 'stops the run' do
      chef_install_resource = ubuntu_1404.package('chef')
      expect(chef_install_resource).to notify('ruby_block[stop chef run]').to(:run).immediately
    end
  end
end
