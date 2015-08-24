require 'spec_helper'

describe 'test::ingredient_config' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'it renders ad hoc config' do
    expect(chef_run).to add_ingredient_config('chef-server')
    expect(chef_run).to render_ingredient_config('chef-server').with(config: "topology 'torus'")
  end
end
