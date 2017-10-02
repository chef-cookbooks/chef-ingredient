chef_server 'chef-server.local' do
  sensitive true
  config "api_fqdn 'chef-server.local'"
  addons manage: { config: 'disable_sign_up false' },
         :"push-jobs-server" => { config: 'whitelist {}' }
end
