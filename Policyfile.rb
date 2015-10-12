name 'chef-ingredient'
run_list 'chef-ingredient::default'
default_source :community

cookbook 'chef-ingredient', path: '.'

cookbook 'test', path: './test/fixtures/cookbooks/test'
