chef_server_url "https://chef.local/organizations/infrastructure"
verify_api_cert false
ssl_verify_mode :verify_none
node_name 'workflow'
client_key '../test/fixtures/config/workflow.pem'
