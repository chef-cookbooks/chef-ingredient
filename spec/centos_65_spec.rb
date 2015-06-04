require 'spec_helper'

describe 'test::repo' do
  cached(:centos_65) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '6.5',
      step_into: 'chef_server_ingredient'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::repo')
  end

  context 'compiling the test recipe' do
    it 'creates packagecloud_repo[chef/stable]' do
      expect(centos_65).to create_packagecloud_repo('chef/stable')
    end

    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(centos_65).to install_chef_server_ingredient('chef-server-core')
    end

    it 'installs yum_package[chef-server-core]' do
      expect(centos_65).to install_yum_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(centos_65).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[opscode-manage]' do
      expect(centos_65).to install_chef_server_ingredient('opscode-manage')
    end

    it 'installs yum_package[opscode-manage]' do
      expect(centos_65).to install_yum_package('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(centos_65).to create_file('/tmp/opscode-manage.firstrun')
    end
  end
end


describe 'test::local' do
  cached(:centos_65) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '6.5',
      step_into: 'chef_server_ingredient'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::local')
  end

  context 'compiling the test recipe' do
    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(centos_65).to install_chef_server_ingredient('chef-server-core')
    end

    it 'uses the rpm_package provider instead of yum_package' do
      expect(centos_65).to install_rpm_package('chef-server-core')
      expect(centos_65).to_not install_yum_package('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(centos_65).to create_file('/tmp/chef-server-core.firstrun')
    end
  end
end
