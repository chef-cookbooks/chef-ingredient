chef_ingredient 'cinc' do
  channel :stable
  version :latest
  rubygems_url 'https://packagecloud.io/cinc-project/stable'
  action :install
end
