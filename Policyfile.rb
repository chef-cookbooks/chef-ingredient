# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'chef-ingredient'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'chef-ingredient::default'
named_run_list :test, 'test'
named_run_list :test_install_git, 'test::install_git'
named_run_list :test_repo, %w(test::install_git test test::repo)
named_run_list :test_local, %w(test::install_git test test::local)
named_run_list :test_chef_workstation, 'test::chef_workstation'
named_run_list :test_inspec, 'test::inspec'
named_run_list :test_chef_server, 'test::chef_server_noaddons'
named_run_list :test_chef_automatev2, 'test::automatev2'

# Specify a custom source for a single cookbook:
cookbook 'chef-ingredient', path: '.'
cookbook 'test', path: './test/fixtures/cookbooks/test'
cookbook 'custom_repo', path: './test/fixtures/cookbooks/custom_repo'
