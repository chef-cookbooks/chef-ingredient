require 'spec_helper'

describe 'test::local' do
  context 'on centos' do
    cached(:centos_65) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'uses the rpm package provider' do
      expect(centos_65).to install_package('chef-server-core').with(provider: Chef::Provider::Package::Rpm)
    end
  end

  context 'on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.set['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'uses the dpkg package provider' do
      expect(ubuntu_1404).to install_package('chef-server-core').with(provider: Chef::Provider::Package::Dpkg)
    end
  end
end
