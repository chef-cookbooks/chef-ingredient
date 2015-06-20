# we probably don't need/want to add this to a test kitchen suite.
# This here so we can test with chefspec, really.
omnibus_service 'chef-server/rabbitmq' do
  action :restart
end

omnibus_service 'chef-server/nginx' do
  action :nothing
end

log 'I tell nginx to stop' do
  notifies :stop, 'omnibus_service[chef-server/nginx]'
end

omnibus_service 'never-never/land' do
  ctl_command 'never-never-ctl'
  action :start
end
