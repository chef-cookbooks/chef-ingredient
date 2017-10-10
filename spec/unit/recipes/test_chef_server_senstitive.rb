require 'spec_helper'

describe 'test::chef_server_sensitive' do
  context 'install chef server' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_server)
      ).converge(described_recipe)
    end

    it 'installs chef server with sensitive true' do
      expect(chef_run).to upgrade_chef_ingredient('chef-server').with(sensitive: true)
      expect(chef_run).to render_ingredient_config('chef-server').with(sensitive: true)
      expect(chef_run).to upgrade_chef_ingredient('manage').with(sensitive: true)
      expect(chef_run).to render_ingredient_config('manage').with(sensitive: true)
    end
  end
end
