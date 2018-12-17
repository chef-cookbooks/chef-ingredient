
chef_automatev2 'automatev2.chefstack.local' do
  config <<~EOS
    [global.v1]
      fqdn = "chef-server.example.com"
  EOS
  accept_license true
end
