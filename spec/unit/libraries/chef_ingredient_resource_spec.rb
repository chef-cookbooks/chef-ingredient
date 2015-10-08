require 'spec_helper'
require 'chef/resource'

describe Chef::Resource::ChefIngredient do
  before(:each) do
    @resource = described_class.new('chef-server')
  end

  describe '#initialize' do
    it 'creates a new Chef::Resource::ChefIngredient with default attrs' do
      expect(@resource).to be_a(Chef::Resource)
      expect(@resource).to be_a(described_class)

      expect(@resource.version).to eql(:latest)
      expect(@resource.channel).to eql(:stable)

      expect(@resource.action).to eql([:install])
      expect(@resource.allowed_actions).to include(:install, :uninstall, :remove, :reconfigure, :upgrade)
    end

    it 'has a resource name of :chef_ingredient' do
      expect(@resource.resource_name).to eql(:chef_ingredient)
    end
  end

  describe '#product_name' do
    it 'is the name attribute by default' do
      resource = described_class.new('manage')
      expect(resource.product_name).to eql('manage')
    end
  end

  describe '#config' do
    it 'requires a String' do
      @resource.config 'my config info'
      expect(@resource.config).to eql('my config info')
      expect { @resource.send(:config, ['r']) }.to raise_error(ArgumentError)
    end
  end

  describe '#package_source' do
    it 'requires an String' do
      @resource.package_source 'my_package_url'
      expect(@resource.package_source).to eql('my_package_url')
      expect { @resource.send(:package_source, ['n']) }.to raise_error(ArgumentError)
    end
  end

  describe '#ctl_command' do
    it 'requires a String' do
      @resource.ctl_command 'burger-clt'
      expect(@resource.ctl_command).to eql('burger-clt')
      expect { @resource.send(:ctl_command, :burger_ctl) }.to raise_error(ArgumentError)
    end
  end

  describe '#channel' do
    it 'requires a Symbol' do
      @resource.channel :current
      expect(@resource.channel).to eql(:current)
      expect { @resource.send(:channel, 'stable') }.to raise_error(ArgumentError)
    end

    it 'cannot be something different than :current or :stable' do
      expect { @resource.send(:channel, :not_expected) }.to raise_error(ArgumentError)
    end
  end

  describe '#version' do
    it 'requires a Symbol or String' do
      @resource.version :cool_symbol
      expect(@resource.version).to eql(:cool_symbol)
      expect { @resource.send(:version, 1) }.to raise_error(ArgumentError)
    end
  end
end
