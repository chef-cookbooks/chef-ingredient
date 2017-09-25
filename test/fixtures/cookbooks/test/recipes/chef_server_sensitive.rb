chef_server 'chef-server.local' do
  sensitive true
  config "can't see me"
  addons manage: { config: "can't see me either" }
end
