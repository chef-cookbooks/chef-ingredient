chef_ingredient 'chef-server' do
  action :install
  channel :unstable
  version :latest
end
