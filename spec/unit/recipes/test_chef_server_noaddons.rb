require 'spec_helper'

describe 'test::chef_server_noaddons' do
  context 'install chef server' do
    cached(:chef_run) do
      stub_search('node', 'name:automate-centos-68').and_return('automate-centos-68')
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_server)
      ).converge(described_recipe)
    end

    it 'installs chef server without addon manage' do
      expect(chef_run).to upgrade_chef_ingredient('chef-server')
      expect(chef_run).to render_ingredient_config('chef-server')
      expect(chef_run).to_not upgrade_chef_ingredient('manage')
      expect(chef_run).to_not render_ingredient_config('manage')
    end
  end
end
