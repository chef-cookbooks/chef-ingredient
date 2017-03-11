require 'spec_helper'

describe 'test::omnitruck_handler' do
  context 'install chef on aix' do
    let(:aix) do
      ChefSpec::SoloRunner.new(
        platform: 'aix',
        version: '7.1',
        step_into: %w(chef_ingredient)
      ).converge(described_recipe)
    end

    it 'use the omnitruck handler' do
      skip 'currently only works when run alone'
      expect(aix).to run_execute('install-chef-latest')
    end
  end
end
