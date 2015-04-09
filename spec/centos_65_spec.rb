require 'spec_helper'

describe 'test::repo' do
  cached(:centos_65) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '6.5'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::repo')
  end

  context 'compiling the test recipe' do
    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(centos_65).to install_chef_server_ingredient('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(centos_65).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[opscode-manage]' do
      expect(centos_65).to install_chef_server_ingredient('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(centos_65).to create_file('/tmp/opscode-manage.firstrun')
    end
  end
end
