require 'spec_helper'

describe 'test::push' do
  [{ platform: 'ubuntu', version: '14.04' },
   { platform: 'centos', version: '6.5' }].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: ['chef_ingredient'])
        ).converge(described_recipe)
      end

      it 'installs the chef_ingredient[push-client]' do
        expect(chef_run).to install_chef_ingredient('push-client')
      end
    end
  end

  context 'installs packages with yum on centos' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.set['test']['push-client']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'creates the yum repository' do
      expect(centos_65).to create_yum_repository('chef-stable')
    end

    it 'upgrades yum_package[push-client]' do
      pkgres = centos_65.find_resource('package', 'push-client')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::YumPackage)
      expect(centos_65).to install_package('push-client')
    end
  end

  context 'install packages with apt on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.set['test']['push-client']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'creates the apt repository' do
      expect(ubuntu_1404).to add_apt_repository('chef-stable')
    end

    it 'upgrades apt_package[push-client]' do
      pkgres = ubuntu_1404.find_resource('package', 'push-client')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::AptPackage)
      expect(ubuntu_1404).to install_package('push-client')
    end
  end
end
