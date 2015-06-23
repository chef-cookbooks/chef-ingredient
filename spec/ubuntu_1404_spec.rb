require 'spec_helper'

describe 'test::repo on ubuntu' do
  context 'compiling the test recipe' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge('test::repo')
    end

    it 'installs chef_ingredient[chef-server-core]' do
      expect(ubuntu_1404).to install_chef_ingredient('chef-server')
    end

    it 'installs apt_package[chef-server-core]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[manage]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('manage')
    end

    it 'installs apt_package[opscode-manage]' do
      expect(ubuntu_1404).to install_apt_package('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/opscode-manage.firstrun')
    end
  end

  context 'release version specified' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(ubuntu_1404).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the release version string' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.0.4-1'
      )
    end
  end

  context 'package iteration version specified' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4-1'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(ubuntu_1404).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the release version string' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.0.4-1'
      )
    end
  end

  context 'release candidate version specified' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.1.0-rc.3'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(ubuntu_1404).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the tilde version separator' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.1.0~rc.3-1'
      )
    end
  end

  context '`latest` is specified for the version as a symbol' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = :latest
      end.converge('test::repo')
    end

    it 'installs chef_ingredient[chef-server]' do
      expect(ubuntu_1404).to install_chef_ingredient('chef-server')
    end

    it 'installs yum_package[chef-server]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end
  end

  context '`latest` is specified for the version as a string' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = 'latest'
      end.converge('test::repo')
    end

    it 'installs chef_ingredient[chef-server]' do
      expect(ubuntu_1404).to install_chef_ingredient('chef-server')
    end

    it 'installs yum_package[chef-server]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end
  end
end

describe 'test::local on ubuntu' do
  context 'compiling the test recipe' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge('test::local')
    end

    it 'installs chef_ingredient[chef-server]' do
      expect(ubuntu_1404).to install_chef_ingredient('chef-server')
    end

    it 'uses the dpkg_package provider instead of apt_package' do
      expect(ubuntu_1404).to install_dpkg_package('chef-server-core')
      expect(ubuntu_1404).to_not install_apt_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/chef-server-core.firstrun')
    end
  end
end
