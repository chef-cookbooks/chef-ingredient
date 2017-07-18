require 'spec_helper'

describe 'test::upgrade' do
  [{ platform: 'ubuntu', version: '14.04' },
   { platform: 'centos', version: '6.9' }].each do |platform|
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
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.9',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades yum_package[chef-server]' do
      # Since we have two resources with same name and identity we can't use
      # the upgrade_package & install_package matchers directly.
      chef_server_resources = centos_6.find_resources(:package)
      expect(chef_server_resources.length).to eq(2)
      expect(chef_server_resources[0].action.first).to eq(:install)
      expect(chef_server_resources[0].package_name).to eq('chef-server-core')
      expect(chef_server_resources[1].action.first).to eq(:upgrade)
      expect(chef_server_resources[1].package_name).to eq('chef-server-core')
    end
  end

  context 'upgrade packages on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        architecture: 'x86_64',
        step_into: %w(chef_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = :latest
      end.converge(described_recipe)
    end

    it 'upgrades package[chef-server]' do
      chef_server_resources = ubuntu_1404.find_resources(:package)
      expect(chef_server_resources.length).to eq(2)
      expect(chef_server_resources[0].action.first).to eq(:install)
      expect(chef_server_resources[0].package_name).to eq('chef-server-core')
      expect(chef_server_resources[1].action.first).to eq(:upgrade)
      expect(chef_server_resources[1].package_name).to eq('chef-server-core')
    end
  end
end
