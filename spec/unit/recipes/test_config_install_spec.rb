require 'spec_helper'

describe 'test::config_install' do
  context "config options for chef-server and one component" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['chef_ingredient', 'ingredient_config']
      ) do |node|
        node.set['chef_admin'] = "admin@chef.io"
      end.converge(described_recipe)
    end

    it "creates config directory" do
      expect(chef_run).to create_directory("/etc/opscode")
      expect(chef_run).to create_directory("/etc/opscode-manage")
      expect(chef_run).to create_file("/etc/opscode/chef-server.rb").with content: <<-EOS
api_fqdn "fauxhai.local"
ip_version "ipv6",
notification_email "admin@chef.io"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
server "FQDN",
  ipaddress: "IP_ADDRESS",
  role: "backend",
  bootstrap: true,
  cluster_ipaddress: "CLUSTER_IPADDRESS"
EOS
      expect(chef_run).to create_file("/etc/opscode-manage/manage.rb").with content: <<-EOS
disable_sign_up true
support_email_address node["chef_admin"]
EOS

    end

  end
end
