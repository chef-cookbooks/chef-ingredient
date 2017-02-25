require 'spec_helper'

describe 'test::chef' do
  context 'install chef' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'installs chef' do
      expect(chef_run).to upgrade_package('chef')
    end

    it 'stops the run' do
      chef_install_resource = chef_run.package('chef')
      expect(chef_install_resource).to notify('ruby_block[stop chef run]').to(:run).immediately
    end
  end
end
