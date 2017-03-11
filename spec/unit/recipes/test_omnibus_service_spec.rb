require 'spec_helper'

describe 'test::omnibus_service' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: ['omnibus_service']
    ).converge(described_recipe)
  end

  let(:log_message) { chef_run.log('I tell nginx to stop') }

  it 'allows the chef-server-core/rabbitmq service to restart' do
    expect(chef_run).to restart_omnibus_service('chef-server/rabbitmq')
  end

  it 'restarts the rabbitmq service' do
    expect(chef_run).to run_execute('chef-server-ctl restart rabbitmq')
  end

  it 'has a log service that notifies the chef server nginx' do
    expect(log_message).to notify('omnibus_service[chef-server/nginx]').to(:stop)
  end

  it 'starts with a made up service' do
    expect(chef_run).to run_execute('never-never-ctl start land')
  end
end
