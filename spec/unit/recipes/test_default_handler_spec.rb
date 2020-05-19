require 'spec_helper'

describe 'test::default_handler' do
  context 'install chef on ubuntu' do
    let(:ubuntu) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '18.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the default handler' do
      expect(ubuntu).to install_package('chef').with(provider: Chef::Provider::Package::Dpkg)
    end
  end

  context 'install chef on suse' do
    let(:suse) do
      ChefSpec::SoloRunner.new(
        platform: 'suse',
        version: '12',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the default handler' do
      expect(suse).to install_package('chef').with(provider: Chef::Provider::Package::Rpm)
    end
  end

  context 'install chef on rhel 6' do
    let(:rhel_6) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '6',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the Yum package provider' do
      expect(rhel_6).to install_package('chef').with(provider: Chef::Provider::Package::Yum)
    end
  end
  context 'install chef on rhel 7' do
    let(:rhel_7) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '7',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the Yum package provider' do
      expect(rhel_7).to install_package('chef').with(provider: Chef::Provider::Package::Yum)
    end
  end
  context 'install chef on rhel 8' do
    let(:rhel_8) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '8',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the Dnf package provider' do
      expect(rhel_8).to install_package('chef').with(provider: Chef::Provider::Package::Dnf)
    end
  end
end
