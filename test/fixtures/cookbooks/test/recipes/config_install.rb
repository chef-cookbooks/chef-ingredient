chef_ingredient "chef-server" do
  config <<-EOS
api_fqdn "#{node["fqdn"]}"
ip_version "ipv6",
notification_email "#{node["chef_admin"]}"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
  action :install
end

chef_ingredient "chef-server" do
  config <<-EOS
server "FQDN",
  ipaddress: "IP_ADDRESS",
  role: "backend",
  bootstrap: true,
  cluster_ipaddress: "CLUSTER_IPADDRESS"
EOS
  action :install
end

chef_ingredient "manage" do
  config <<-EOS
disable_sign_up true
support_email_address node["chef_admin"]
EOS
  action :install
end

ingredient_config "manage" do
  notifies :reconfigure, "chef_ingredient[manage]"
end

ingredient_config "chef-server" do
  notifies :reconfigure, "chef_ingredient[chef-server]"
end
