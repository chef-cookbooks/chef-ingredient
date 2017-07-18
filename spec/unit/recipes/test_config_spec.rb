require 'spec_helper'

describe 'test::config' do
  [
    { platform: 'ubuntu', version: '14.04' },
    { platform: 'centos', version: '6.9' },
  ].each do |platform|
    context "non-platform specific resources on #{platform[:platform]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform.merge(step_into: %w(chef_ingredient ingredient_config))
        ) do |node|
          node.normal['chef_admin'] = 'admin@chef.io'
        end.converge(described_recipe)
      end

      it 'reconfigure chef_ingredient[chef-server]' do
        expect(chef_run).to reconfigure_chef_ingredient('chef-server')
      end

      it 'renders config file using ingredient_config' do
        expect(chef_run).to render_ingredient_config('chef-server')
      end

      it 'creates config directory for chef-server' do
        expect(chef_run).to create_directory('/etc/opscode')
      end

      it 'creates config file for chef-server with default of false for sensitive' do
        expect(chef_run).to create_file('/etc/opscode/chef-server.rb').with sensitive: false, content: <<-EOS
api_fqdn "fauxhai.local"
ip_version "ipv6"
notification_email "admin@chef.io"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
      end

      it 'reconfigure chef_ingredient[manage]' do
        expect(chef_run).to reconfigure_chef_ingredient('manage')
      end

      it 'creates the directory for the license acceptance file' do
        expect(chef_run).to create_directory('/var/opt/chef-manage').with(recursive: true)
      end

      it 'creates the license acceptance file' do
        expect(chef_run).to touch_file('/var/opt/chef-manage/.license.accepted')
      end

      it 'does not render config file using ingredient_config' do
        expect(chef_run).to_not render_ingredient_config('manage')
      end

      it 'does not create config directory for manage' do
        expect(chef_run).to_not create_directory('/etc/opscode-manage')
      end

      it 'does not create config file for manage' do
        expect(chef_run).to_not create_file('/etc/opscode-manage/manage.rb')
      end
    end
  end
end
