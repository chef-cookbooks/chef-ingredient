chef_file '/tmp/remote_file' do
  source 'https://www.example.com/test'
  user 'root'
  group 'root'
  mode '0600'
end

chef_file '/tmp/cookbook_file' do
  source 'cookbook_file://chef_test::testfile'
  user 'root'
  group 'root'
  mode '0600'
end

chef_file '/tmp/file' do
  source 'abcdef'
  user 'root'
  group 'root'
  mode '0600'
end
