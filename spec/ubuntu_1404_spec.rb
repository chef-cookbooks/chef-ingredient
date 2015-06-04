require 'spec_helper'

describe 'test::repo' do
  cached(:ubuntu_1404) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'chef_server_ingredient'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::repo')
  end

  context 'compiling the test recipe' do
    it 'creates packagecloud_repo[chef/stable]' do
      expect(ubuntu_1404).to create_packagecloud_repo('chef/stable')
    end

    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('chef-server-core')
    end

    it 'installs apt_package[chef-server-core]' do
      expect(ubuntu_1404).to install_apt_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[opscode-manage]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('opscode-manage')
    end

    it 'installs apt_package[opscode-manage]' do
      expect(ubuntu_1404).to install_apt_package('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/opscode-manage.firstrun')
    end
  end
end

describe 'test::local' do
  cached(:ubuntu_1404) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'chef_server_ingredient'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::local')
  end

  context 'compiling the test recipe' do
    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('chef-server-core')
    end

    it 'uses the rpm_package provider instead of yum_package' do
      expect(ubuntu_1404).to install_dpkg_package('chef-server-core')
      expect(ubuntu_1404).to_not install_apt_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/chef-server-core.firstrun')
    end
  end
end
