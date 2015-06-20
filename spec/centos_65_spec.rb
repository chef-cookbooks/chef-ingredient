require 'spec_helper'

describe 'test::repo on centos' do
  context 'compiling the test recipe' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge('test::repo')
    end

    it 'installs chef_ingredient[chef-server]' do
      expect(centos_65).to install_chef_ingredient('chef-server')
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_65).to install_yum_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(centos_65).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[manage]' do
      expect(centos_65).to install_chef_server_ingredient('manage')
    end

    it 'installs yum_package[opscode-manage]' do
      expect(centos_65).to install_yum_package('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(centos_65).to create_file('/tmp/opscode-manage.firstrun')
    end
  end

  context 'release version specified' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(centos_65).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the release version string' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.0.4-1.el6'
      )
    end
  end

  context 'package iteration version specified' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4-1'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(centos_65).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the release version string' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.0.4-1.el6'
      )
    end
  end

  context 'release candidate version specified' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.1.0-rc.3'
      end.converge('test::repo')
    end

    it 'installs the mixlib-versioning gem' do
      expect(centos_65).to install_chef_gem('mixlib-versioning')
    end

    it 'installs the package with the tilde version separator and release identifier' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.1.0~rc.3-1.el6'
      )
    end
  end
end

describe 'test::local on centos' do
  context 'compiling the test recipe' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge('test::local')
    end

    it 'installs chef_ingredient[chef-server-core]' do
      expect(centos_65).to install_chef_ingredient('chef-server')
    end

    it 'uses the rpm_package provider instead of yum_package' do
      expect(centos_65).to install_rpm_package('chef-server-core')
      expect(centos_65).to_not install_yum_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(centos_65).to create_file('/tmp/chef-server-core.firstrun')
    end
  end
end
