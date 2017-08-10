require 'spec_helper'

describe 'test::local' do
  context 'on centos' do
    cached(:centos_6) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.9',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'uses the Yum package provider' do
      expect(centos_6).to install_package('chef-server-core').with(provider: Chef::Provider::Package::Yum)
    end
  end

  context 'on ubuntu' do
    cached(:ubuntu_1404) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient chef_server_ingredient)
      ) do |node|
        node.normal['chef-server-core']['version'] = nil
      end.converge(described_recipe)
    end

    it 'uses the dpkg package provider' do
      expect(ubuntu_1404).to install_package('chef-server-core').with(provider: Chef::Provider::Package::Dpkg)
    end
  end
end
