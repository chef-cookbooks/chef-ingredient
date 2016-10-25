require 'spec_helper'

describe 'test::handlers' do
  context 'install chef on aix' do
    cached(:aix) do
      ChefSpec::SoloRunner.new(
        platform: 'aix',
        version: '7.1',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the omnitruck handler' do
      skip 'chefspec instance mocking issue'
      expect(aix).to run_execute('install-chef-latest').with(command: 'sudo /bin/sh installer.sh')
    end
  end

  context 'install chef on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the default handler' do
      expect(ubuntu_1404).to install_package('chef').with(provider: Chef::Provider::Package::Dpkg)
    end
  end

  context 'install chef on suse' do
    cached(:suse) do
      ChefSpec::SoloRunner.new(
        platform: 'suse',
        version: '12.1',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the default handler' do
      expect(suse).to install_package('chef').with(provider: Chef::Provider::Package::Rpm)
    end
  end
end
