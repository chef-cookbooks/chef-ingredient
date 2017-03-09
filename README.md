# chef_stack

Chef stack is a library cookbook that provides custom resources to build and manage your Chef infrastructure.

An accompanying project |  [Chef-Services](https//github.com/stephenlauck/chef-services) exists as an example implementation of Chef Stack.

## Custom Resources

Below are the custom resources provided by this cookbook |  their uses |  and their properties

### General Properties

These properties exist for all resources

| Name  | Type | Default Value  |  Description  |
|---|---|---|---|---|
| name  | String  | N/A | A name for the resource |
| channel  | Symbol  | stable  | The channel from our package repository to install. Most of the time you want stable.  |
| version  | [String,  Symbol]  | latest  | The version of Automate you want to install  |
| config  | String  |  N/A | The configuration that will be written to the appropriate configuration file for the product.  |
| accept_license  | [TrueClass, FalseClass]  | false | Do you accept Chef's license agreements.  |
| platform  | String  | Auto-detected | Use only if you need to over-ride the default platform.  |
| platform_version  | String  | Auto-detected | Use only if you need to over-ride the default platform.  |


### chef_automate

Installs Chef Automate.

#### Properties
| Name  | Type | Default Value  |  Description  |
|---|---|---|---|---|
| enterprise  | [String,  Array]  | chef | The Enterprise to create in Automate|
| license  | String  | N/A  | Your license file |  we recommend using the chef_file resource |
| chef_user  | String  | workflow  | The user you will connect to the Chef server as  |
| chef_user_pem  | String  |  N/A | The private key of the above Chef user   |
| validation_pem  | String  |  N/A | The validator key of the Chef org we're connecting to   |
| builder_pem  | String  |  N/A | The private key of the build nodes |

### chef_backend

#### Properties

| Name  | Type | Default Value  |  Description  |
|---|---|---|---|---|
| bootstrap_node  | String  | N/A | The node we'll bootstrap secrets with. |
| publish_address  | String  | node['ipaddress']  | The address you want Chef-Backend to listen on. |
| chef_backend_secrets  | String  | nil  | A location where your secrets are |  we recommend using the chef_file resource. |

### chef_org

#### Properties


| Name  | Type | Default Value  |  Description  |
|---|---|---|---|---|
| org  | String  | N/A | The short name of the org. |
| org_full_name  | String  | node['ipaddress']  | The full name of the org you want to create. |
| admins  | Array  | N/A  | An array of admins for the org. |
| users  | Array  | []  | An array of users for the org. |
| remove_users  | Array  | [] | An array of users to remove from  the org. |
| key_path  | String  | N/A | Where to store the validator key that is created with the org. |

### chef_user

| Name  | Type | Default Value  |  Description  |
 |---|---|---|---|
| username  | String  | N/A | The username of the user. |
| first_name  | String  | N/A  | The first name of the user. |
| last_name  | Array  | N/A  | The last name of the user. |
| email  | Array  | []  | N/A  | The users e-mail. |
| password  | Array  | [] | The users password. |
| key_path  | String  | N/A | Where to store the users private key that is created with the user. |
| serveradmin  | [TrueClass,  FalseClass]  | F | Is the user a serveradmin? |

### chef_client
| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| node_name |  String | true | |
| versio [String, Symbol] | latest | |
| chefdk |  [TrueClass, FalseClass] | false | |
| chef_server_url |  [String, Symbol] | local | |
| ssl_verif [TrueClass, FalseClass] | true | |
| log_locatio String | 'STDOUT' | |
| log_level |  Symbol | auto | |
| config |  String | | |
| run_list |  Arra| |
| environment |  String | | |
| validation_pem |  String | | |
| validation_client_name |  String | | |
| tags |  [String, Array] |   '' | |
| interval |  Integer |   1800 | |
| spla Integer |   1800 | |
| data_collector_toke String |  '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | |
| data_collector_url |  String | | |

### chef_file


| Name  | Type | Default Value  | Description  |
|---|---|---|---|
|  filename | String | | |
|  source |  String | | |
|  user |  String |  default 'root' | |
|  group |  String |  default 'root' | |
|  mode |  String |  default '0600' | |

### chef_server

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
|  addons |  Hash | | |
|  data_collector_toke String |  default '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | |
|  data_collector_url |  String | | |

### chef_supermarket

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| chef_server_url |  String |  Chef::Config['chef_server_url'] | |
| chef_oauth2_app_id |  String |  | |
| chef_oauth2_secret |  String |  | |
| chef_oauth2_verify_ssl |  [TrueClass, FalseClass] |  true | |

### workflow_builder

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| pj_versio [String, Symbol] | :latest | |
| accept_license |  [TrueClass, FalseClass] | false | |
| chef_user |  String | 'workflow' | |
| chef_user_pem |  String |  | |  
| builder_pem |  String |  | |  
| chef_fqd String |   URI.parse(Chef::Config['chef_server_url']).host | |
| automate_fqd String | | | |
| supermarket_fqd String | | |
| job_dispatch_versio String | 'v2' | |
| automate_user |  String | 'admin' | |
| automate_password |  String | | |
| automate_enterprise |  String | 'chef' | |
| chef_config_path |  String | '/etc/chef/client.rb' | |
