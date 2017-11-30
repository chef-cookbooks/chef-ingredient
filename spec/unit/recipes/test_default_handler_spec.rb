require 'spec_helper'

describe 'test::default_handler' do
  context 'install chef on ubuntu' do
    let(:ubuntu_1404) do
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
    let(:suse) do
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

  context 'install chef on rhel 5' do
    let(:rhel_5) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '5.10',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the RPM package provider' do
      expect(rhel_5).to install_package('chef').with(provider: Chef::Provider::Package::Rpm)
    end
  end

  context 'install chef on rhel 6' do
    let(:rhel_6) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '6.9',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the Yum package provider' do
      expect(rhel_6).to install_package('chef').with(provider: Chef::Provider::Package::Yum)
    end
  end
end
