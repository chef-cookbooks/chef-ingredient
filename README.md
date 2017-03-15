# chef_stack

Chef stack is a library cookbook that provides custom resources to build and manage your Chef infrastructure.

An accompanying project, [Chef-Services](https//github.com/stephenlauck/chef-services) exists as an example implementation of Chef Stack.

## Custom Resources

Below are the custom resources provided by this cookbook.

### General Properties

These properties exist for all resources

| Name  | Type | Default Value  |  Description  |
|---|---|---|---|
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
|---|---|---|---|
| enterprise  | [String,  Array]  | chef | The Enterprise to create in Automate|
| license  | String  | N/A  | Your license file |  we recommend using the chef_file resource |
| chef_user  | String  | workflow  | The user you will connect to the Chef server as  |
| chef_user_pem  | String  |  N/A | The private key of the above Chef user   |
| validation_pem  | String  |  N/A | The validator key of the Chef org we're connecting to   |
| builder_pem  | String  |  N/A | The private key of the build nodes |

### chef_backend

#### Properties

| Name  | Type | Default Value  |  Description  |
|---|---|---|---|
| bootstrap_node  | String  | N/A | The node we'll bootstrap secrets with. |
| publish_address  | String  | node['ipaddress']  | The address you want Chef-Backend to listen on. |
| chef_backend_secrets  | String  | nil  | A location where your secrets are |  we recommend using the chef_file resource. |

### chef_org

#### Properties


| Name  | Type | Default Value  |  Description  |
|---|---|---|---|
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
| node_name |  String | true | The name of the node. |
| version | [String, Symbol] | latest | The version of chef-client to install. |
| chefdk |  [TrueClass, FalseClass] | false | Do you want to install chefdk? |
| chef_server_url |  [String, Symbol] | local | What is hte Chef server URL to connect to. |
| ssl_verify | [TrueClass, FalseClass] | true | Validate ssl certificates? |
| log_location | String | 'STDOUT' | Where to log. |
| log_level |  Symbol | auto | Log level. |
| config |  String | | Any configuration for client.rb. |
| run_list |  Array | | The clients runlist. |
| environment |  String | | Which Chef Environment the client belongs to. |
| validation_pem |  String | | The validation pem to validate with. |
| validation_client_name |  String | | The validation client name. |
| tags |  [String, Array] |   '' | Any tags for the node. |
| interval |  Integer |   1800 | The interval to run chef-client on. |
| splay | Integer |   1800 | The randomization to add to the interval. |
| data_collector_token | String |  '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | The data collector token to talk to Visibility. |
| data_collector_url |  String | | The Visibility URL to send data. |

### chef_file


| Name  | Type | Default Value  | Description  |
|---|---|---|---|
|  filename | String | | The name of the resource. |
|  source |  String | | The source of the file. |
|  user |  String |  default 'root' | The owner of the file. |
|  group |  String |  default 'root' | The group owner of the file. |
|  mode |  String |  default '0600' | The mode for the file. |

### chef_server

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
|  addons |  Hash | | A set of addons to install with the Chef Server. |
|  data_collector_token | String |  default '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | The data collector token to authenticate with Chef Visiblity. |
|  data_collector_url |  String | | The URL to connect to Visibility. |

### chef_supermarket

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| chef_server_url |  String |  Chef::Config['chef_server_url'] | The Chef server's URL. |
| chef_oauth2_app_id |  String |  | The oauth2 app id from the Chef server. |
| chef_oauth2_secret |  String |  | The oauth2 secret from the Chef server. |
| chef_oauth2_verify_ssl |  [TrueClass, FalseClass] |  true | Whether to validate SSL certificates. |

### workflow_builder

| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| pj_version | [String, Symbol] | :latest | The version of Push-Jobs to install. |
| chef_user |  String | 'workflow' | The Chef user to authenticate with the Chef Server. |
| chef_user_pem |  String |  | The private key of the Chef user to authenticate with the Chef Server. |  
| builder_pem |  String |  | The builder users private key to communicate with Chef Automate. |  
| chef_fqdn | String |   URI.parse(Chef::Config['chef_server_url']).host | The FQDN of the Chef server. |
| automate_fqdn | String | | | The FQDN of the automate server. |
| supermarket_fqdn | String | | The FQDN of the Supermarket server. |
| job_dispatch_version | String | 'v2' | Which job dispatch version to use. V1 is push-jobs, V2 is SSH runners. |
| automate_user |  String | 'admin' | What is the Automate user we're connecting to Automate as. |
| automate_password |  String | | The password for the user above. |
| automate_enterprise |  String | 'chef' | The Enterprise to connect to. |
| chef_config_path |  String | '/etc/chef/client.rb' | The config path for chef-client. |
