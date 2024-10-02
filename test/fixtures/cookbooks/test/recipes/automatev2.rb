chef_automatev2 'automatev2.chefstack.local' do
  config <<~EOS
    [global.v1]
      fqdn = "chef-automate.example.com"
  EOS
  products %w(automate infra-server builder desktop)
  accept_license true
  skip_preflight true
end
