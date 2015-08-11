require 'spec_helper'

describe 'test::upgrade' do
  [{ platform: 'ubuntu', version: '14.04' },
   { platform: 'centos', version: '6.5' }].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: ['chef_ingredient'])
        ).converge(described_recipe)
      end

      it 'upgrades the chef_ingredient[chef-server]' do
        expect(chef_run).to upgrade_chef_ingredient('chef-server')
      end
    end
  end

  context 'upgrade packages with yum on centos' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades yum_package[chef-server]' do
      expect(centos_65).to upgrade_package('chef-server-core')
    end
  end

  context 'upgrade packages with apt on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades apt_package[chef-server]' do
      expect(ubuntu_1404).to upgrade_package('chef-server-core')
    end
  end
end
