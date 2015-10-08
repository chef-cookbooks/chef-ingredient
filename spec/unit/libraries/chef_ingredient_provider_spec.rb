require 'spec_helper'
require 'chef/node'
require 'chef/event_dispatch/dispatcher'
require 'chef/run_context'

describe Chef::Provider::ChefIngredient do
  let(:node) { Chef::Node.new }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:new_resource) { Chef::Resource::ChefIngredient.new('delivery', run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  before do
    new_resource.config = 'my cool config'
  end

  it 'is a Chef::Provider::ChefIngredient Object' do
    expect(provider).to be_a(Chef::Provider::ChefIngredient)
  end

  describe '#action_install' do
    it 'marks ingredient as installed' do
      expect(provider).to receive(:install_mixlib_versioning)
      expect(provider).to receive(:declare_chef_run_stop_resource)
      expect(provider).to receive(:add_config)
        .with('delivery', 'my cool config')
      expect(provider).to receive(:handle_install)
      provider.run_action(:install)
    end
  end

  describe '#action_upgrade' do
    it 'marks ingredient as upgraded' do
      expect(provider).to receive(:install_mixlib_versioning)
      expect(provider).to receive(:declare_chef_run_stop_resource)
      expect(provider).to receive(:add_config)
        .with('delivery', 'my cool config')
      expect(provider).to receive(:handle_upgrade)
      provider.run_action(:upgrade)
    end
  end

  describe '#action_uninstall' do
    it 'marks ingredient as uninstalled' do
      expect(provider).to receive(:install_mixlib_versioning)
      expect(provider).to_not receive(:declare_chef_run_stop_resource)
      expect(provider).to receive(:handle_uninstall)
      provider.run_action(:uninstall)
    end
  end

  describe '#action_reconfigure' do
    it 'marks ingredient as reconfigured' do
      expect(provider).to receive(:install_mixlib_versioning)
      expect(provider).to_not receive(:declare_chef_run_stop_resource)
      expect(provider).to receive(:add_config)
        .with('delivery', 'my cool config')
      expect(provider).to receive(:ingredient_config).with('delivery')
      expect(provider).to receive(:execute).with('delivery-reconfigure')
      provider.run_action(:reconfigure)
    end
  end
end
