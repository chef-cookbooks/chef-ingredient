require 'spec_helper'

describe 'test::push' do
  [{ platform: 'ubuntu', version: '18.04' },
   { platform: 'centos', version: '6' }].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: ['chef_ingredient'])
        ).converge(described_recipe)
      end

      it 'installs the chef_ingredient[push-jobs-client]' do
        expect(chef_run).to install_chef_ingredient('push-jobs-client')
      end
    end
  end

  context 'installs packages with yum on centos' do
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.normal['test']['push-client']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades package[push-client]' do
      pkgres = centos_6.find_resource('package', 'push-jobs-client')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(centos_6).to install_package('push-jobs-client')
    end
  end

  context 'install packages on ubuntu' do
    cached(:ubuntu) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '18.04',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.normal['test']['push-client']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades package[push-client]' do
      pkgres = ubuntu.find_resource('package', 'push-jobs-client')
      expect(pkgres).to_not be_nil
      expect(pkgres).to be_a(Chef::Resource::Package)
      expect(ubuntu).to install_package('push-jobs-client')
    end
  end
end
