require 'spec_helper'

describe 'test::repo' do
  [{ platform: 'ubuntu', version: '14.04' },
   { platform: 'centos', version: '6.9' }].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: %w(chef_ingredient ingredient_config))
        ) do |node|
          node.normal['chef_admin'] = 'admin@chef.io'
        end.converge(described_recipe)
      end

      it 'installs chef_ingredient[chef-server]' do
        expect(chef_run).to install_chef_ingredient('chef-server')
      end

      it 'creates file[/tmp/chef-server-core.firstrun]' do
        expect(chef_run).to create_file('/tmp/chef-server-core.firstrun')
      end

      it 'creates config directory for chef-server' do
        expect(chef_run).to create_directory('/etc/opscode')
      end

      it 'creates config file for chef-server with default of false for sensitive' do
        expect(chef_run).to create_file('/etc/opscode/chef-server.rb').with sensitive: false, content: <<-EOS
api_fqdn "fauxhai.local"
ip_version "ipv6"
notification_email "admin@chef.io"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
      end

      it 'uses ingredient_config to notify a reconfigure for chef-server' do
        resource = chef_run.find_resource('ingredient_config', 'chef-server')
        expect(resource).to notify('chef_ingredient[chef-server]')
      end

      it 'installs chef_ingredient[manage]' do
        expect(chef_run).to install_chef_ingredient('manage')
      end

      it 'creates file[/tmp/opscode-manage.firstrun]' do
        expect(chef_run).to create_file('/tmp/opscode-manage.firstrun')
      end

      it 'creates config directory for manage' do
        expect(chef_run).to create_directory('/etc/chef-manage')
      end

      it 'creates config file for manage with sensitive set' do
        expect(chef_run).to create_file('/etc/chef-manage/manage.rb').with sensitive: true, content: <<-EOS
disable_sign_up true
support_email_address "admin@chef.io"
EOS
      end

      it 'uses ingredient_config to notify a reconfigure for manage' do
        resource = chef_run.find_resource('ingredient_config', 'manage')
        expect(resource).to notify('chef_ingredient[manage]')
      end
    end
  end

  context 'install packages with yum on centos' do
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.9',
        step_into: %w(chef_ingredient chef_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs package[chef-server]' do
      pkgres = centos_6.find_resource('package', 'chef-server')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(centos_6).to install_package('chef-server')
    end

    it 'installs package[opscode-manage]' do
      pkgres = centos_6.find_resource('package', 'manage')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(centos_6).to install_package('manage')
    end
  end

  context ':latest is specified for the version as a symbol' do
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.9',
        step_into: ['chef_ingredient']
      ) do |node|
        node.normal['test']['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_6).to install_package('chef-server-core')
    end
  end

  context 'latest is specified for the version as a string' do
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.9',
        step_into: ['chef_ingredient']
      ) do |node|
        node.normal['test']['chef-server-core']['version'] = 'latest'
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(centos_6).to install_package('chef-server-core')
    end
  end

  context 'installs packages with apt on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server-core]' do
      pkgres = ubuntu_1404.find_resource('package', 'chef-server')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::AptPackage)
      expect(ubuntu_1404).to install_package('chef-server')
    end

    it 'installs apt_package[opscode-manage]' do
      pkgres = ubuntu_1404.find_resource('package', 'manage')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::AptPackage)
      expect(ubuntu_1404).to install_package('manage')
    end
  end

  context ':latest is specified for the version as a symbol' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.normal['test']['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'installs yum_package[chef-server]' do
      expect(ubuntu_1404).to install_package('chef-server-core')
    end
  end

  context 'latest is specified for the version as a string' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient']
      ) do |node|
        node.normal['test']['chef-server-core']['version'] = 'latest'
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server]' do
      expect(ubuntu_1404).to install_package('chef-server-core')
    end
  end
end
