require 'spec_helper'

describe 'test::repo' do
  cached(:ubuntu_1404) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04'
      ) do |node|
      node.set['chef-server-core']['version'] = nil
    end.converge('test::repo')
  end

  context 'compiling the test recipe' do
    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('chef-server-core')
    end

    it 'creates file[/tmp/chef-server-core.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/chef-server-core.firstrun')
    end

    it 'installs chef_server_ingredient[opscode-manage]' do
      expect(ubuntu_1404).to install_chef_server_ingredient('opscode-manage')
    end

    it 'creates file[/tmp/opscode-manage.firstrun]' do
      expect(ubuntu_1404).to create_file('/tmp/opscode-manage.firstrun')
    end
  end
end
