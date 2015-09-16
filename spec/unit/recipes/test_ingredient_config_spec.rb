require 'spec_helper'

describe 'test::ingredient_config' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['ingredient_config']
    ).converge(described_recipe)
  end

  it 'it renders ad hoc config' do
    expect(chef_run).to create_file('/etc/opscode/chef-server.rb').with(content: "topology 'torus'")
  end
end
