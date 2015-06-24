require 'spec_helper'

describe 'test::repo' do
  [{ platform: 'ubuntu', version: '14.04' },
   { platform: 'centos', version: '6.5' }].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: ['chef_ingredient'])
        ).converge(described_recipe)
      end

      it 'installs chef_ingredient[chef-server]' do
        expect(chef_run).to install_chef_ingredient('chef-server')
      end

      it 'installs the mixlib-versioning gem' do
        expect(chef_run).to install_chef_gem('mixlib-versioning')
      end

      it 'creates file[/tmp/chef-server-core.firstrun]' do
        expect(chef_run).to create_file('/tmp/chef-server-core.firstrun')
      end

      it 'uses /tmp/chef-server-core.firstrun to notify a reconfigure' do
        resource = chef_run.file('/tmp/chef-server-core.firstrun')
        expect(resource).to notify('chef_ingredient[chef-server]')
      end

      it 'installs chef_server_ingredient[manage]' do
        expect(chef_run).to install_chef_server_ingredient('manage')
      end

      it 'creates file[/tmp/opscode-manage.firstrun]' do
        expect(chef_run).to create_file('/tmp/opscode-manage.firstrun')
      end
    end
  end

  context 'install packages with yum on centos' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_65).to install_yum_package('chef-server-core')
    end

    it 'installs yum_package[opscode-manage]' do
      expect(centos_65).to install_yum_package('opscode-manage')
    end
  end

  context 'release version specified as 12.0.4' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4'
      end.converge(described_recipe)
    end

    it 'installs the package with the release version string and el6' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.0.4-1.el6'
      )
    end
  end

  context 'package iteration version specified as 12.0.4-1' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4-1'
      end.converge(described_recipe)
    end

    it 'installs the package with the release version string and el6' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.0.4-1.el6'
      )
    end
  end

  context 'release candidate version specified as 12.1.0-rc.3' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.1.0-rc.3'
      end.converge(described_recipe)
    end

    it 'installs the package with the tilde version separator and release identifier and el6' do
      expect(centos_65).to install_yum_package('chef-server-core').with(
        version: '12.1.0~rc.3-1.el6'
      )
    end
  end

  context ':latest is specified for the version as a symbol' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_65).to install_yum_package('chef-server-core')
    end
  end

  context 'latest is specified for the version as a string' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = 'latest'
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_65).to install_yum_package('chef-server-core')
    end
  end

  context 'installs packages with apt on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server-core]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end

    it 'installs apt_package[opscode-manage]' do
      expect(ubuntu_1404).to install_apt_package('opscode-manage')
    end
  end

  context 'release version specified 12.0.4' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4'
      end.converge(described_recipe)
    end

    it 'installs the package with the release version string' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.0.4-1'
      )
    end
  end

  context 'package iteration version specified 12.0.4-1' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.0.4-1'
      end.converge(described_recipe)
    end

    it 'installs the package with the release version string' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.0.4-1'
      )
    end
  end

  context 'release candidate version specified, 12.1.0-rc.3' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = '12.1.0-rc.3'
      end.converge(described_recipe)
    end

    it 'installs the package with the tilde version separator' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core').with(
        version: '12.1.0~rc.3-1'
      )
    end
  end

  context ':latest is specified for the version as a symbol' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end
  end

  context 'latest is specified for the version as a string' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.set['test']['chef-server-core']['version'] = 'latest'
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end
  end
end
