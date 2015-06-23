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

    it 'uses the rpm_package provider instead of yum_package' do
      expect(centos_65).to install_rpm_package('chef-server-core')
      expect(centos_65).to_not install_yum_package('chef-server-core')
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

    it 'uses the dpkg_package provider instead of apt_package' do
      expect(ubuntu_1404).to install_dpkg_package('chef-server-core')
      expect(ubuntu_1404).to_not install_apt_package('chef-server-core')
    end
  end
end
