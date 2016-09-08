require 'spec_helper'

describe 'test::custom_repo_setup_recipe' do
  context 'on centos' do
    cached(:centos_67) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.7',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'does not creates the yum repository' do
      expect(centos_67).to_not create_yum_repository('chef-stable')
    end

    it 'installs yum_package[chef-server]' do
      pkgres = centos_67.find_resource('package', 'chef-server')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::YumPackage)
      expect(centos_67).to install_package('chef-server')
    end

    it 'includes the custom_repo_setup_recipe' do
      expect(centos_67).to include_recipe 'custom_repo::awesome_custom_setup'
    end
  end

  context 'on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'does not sets up current apt repository' do
      expect(ubuntu_1404).to_not add_apt_repository('chef-stable')
    end

    it 'does not pins future installs of chef to current repository' do
      expect(ubuntu_1404).to_not add_apt_preference('chef').with(pin: 'release o=https://packagecloud.io/chef/current',
                                                                 pin_priority: '900')
    end

    it 'installs chef' do
      expect(ubuntu_1404).to install_package('chef-server')
    end

    it 'includes the custom_repo_setup_recipe' do
      expect(ubuntu_1404).to include_recipe 'custom_repo::awesome_custom_setup'
    end
  end

  context 'installs packages with apt options on ubuntu 10.04' do
    cached(:ubuntu_1004) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '10.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server-core]' do
      pkgres = ubuntu_1004.find_resource('package', 'chef-server')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(ubuntu_1004).to install_package('chef-server').with(options: '--force-yes')
    end
  end

  context 'installs packages with apt options on debian 6' do
    cached(:debian_605) do
      ChefSpec::SoloRunner.new(
        platform: 'debian',
        version: '6.0.5',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'installs apt_package[chef-server-core]' do
      pkgres = debian_605.find_resource('package', 'chef-server')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(debian_605).to install_package('chef-server').with(options: '--force-yes')
    end
  end
end
