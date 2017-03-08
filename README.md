# chef_stack

Chef stack is a library cookbook that provides custom resources to build and manage your Chef infrastructure.

An accompanying project |  [Chef-Services](https//github.com/stephenlauck/chef-services) exists as an example implementation of Chef Stack.

## Custom Resources

Below are the custom resources provided by this cookbook |  their uses |  and their properties

### General Properties

These properties exist for all resources

| Name  | Type | Default Value  | Required? | Description  |
|---|---|---|---|---|
| name  | String  | N/A | Y | A name for the resource (this is the name |)|
| channel  | Symbol  | stable  | Y | The channel from our package repository to install. Most of the time you want stable.  |
| version  | [String |  Symbol]  | latest  | Y  | The version of Automate you want to install  |
| config  | String  |  N/A | Y  | The configuration that will be written to the appropriate configuration file for the product.  |
| accept_license  | [TrueClass |  FalseClass]  | false | Y  | Do you accept Chef's license agreements.  |
| platform  | String  | Auto-detected | N  | Use only if you need to over-ride the default platform.  |
| platform_version  | String  | Auto-detected | N  | Use only if you need to over-ride the default platform.  |


### chef_automate

Installs Chef Automate.

#### Properties
| Name  | Type | Default Value  | Required? | Description  |
|---|---|---|---|---|
| enterprise  | [String |  Array]  | chef | N | The Enterprise to create in Automate|
| license  | String  | N/A  | N | Your license file |  we recommend using the chef_file resource |
| chef_user  | String  | workflow  | N  | The user you will connect to the Chef server as  |
| chef_user_pem  | String  |  N/A | Y  | The private key of the above Chef user   |
| validation_pem  | String  |  N/A | Y  | The validator key of the Chef org we're connecting to   |
| builder_pem  | String  |  N/A | Y  | The private key of the build nodes |

### chef_backend

#### Properties

| Name  | Type | Default Value  | Required? | Description  |
|---|---|---|---|---|
| bootstrap_node  | String  | N/A | Y | The node we'll bootstrap secrets with. |
| publish_address  | String  | node['ipaddress']  | N | The address you want Chef-Backend to listen on. |
| chef_backend_secrets  | String  | nil  | N  | A location where your secrets are |  we recommend using the chef_file resource. |

### chef_org

#### Properties


| Name  | Type | Default Value  | Required? | Description  |
|---|---|---|---|---|
| org  | String  | N/A | Y | The short name of the org. |
| org_full_name  | String  | node['ipaddress']  | N | The full name of the org you want to create. |
| admins  | Array  | N/A  | Y  | An array of admins for the org. |
| users  | Array  | []  | Y  | An array of users for the org. |
| remove_users  | Array  | [] | Y  | An array of users to remove from  the org. |
| key_path  | String  | N/A | N | Where to store the validator key that is created with the org. |

### chef_user

| Name  | Type | Default Value  | Required? | Description  |
|---|---|---|---|---|
| username  | String  | N/A | Y | The username of the user. |
| first_name  | String  | N/A  | N | The first name of the user. |
| last_name  | Array  | N/A  | Y  | The last name of the user. |
| email  | Array  | []  | N/A  | The users e-mail. |
| password  | Array  | [] | Y  | The users password. |
| key_path  | String  | N/A | N | Where to store the users private key that is created with the user. |
| serveradmin  | [TrueClass |  FalseClass]  | F | N | Is the user a serveradmin? |

### chef_client
| Name  | Type | Default Value  | Description  |
|---|---|---|---|
| node_name |  String | true | |
| version |  [String, Symbol] | latest | |
| chefdk |  [TrueClass, FalseClass] | false | |
| chef_server_url |  [String, Symbol] | local | |
| ssl_verify |  [TrueClass, FalseClass] | true | |
| log_location |  String | 'STDOUT' | |
| log_level |  Symbol | auto | |
| config |  String | | |
| run_list |  Array | | |
| environment |  String | | |
| validation_pem |  String | | |
| validation_client_name |  String | | |
| tags |  [String, Array] |   '' | |
| interval |  Integer |   1800 | |
| splay |  Integer |   1800 | |
| data_collector_token |  String |  '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | |
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
|  data_collector_token |  String |  default '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506' | |
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
| pj_version |  [String, Symbol] |  default: :latest | |
| accept_license |  [TrueClass, FalseClass] |  default: false | |
| chef_user |  String |  default: 'workflow' | |
| chef_user_pem |  String |  | |  
| builder_pem |  String |  | |  
| chef_fqdn |  String |  default: URI.parse(Chef::Config['chef_server_url']).host | |
| automate_fqdn |  String |  | | |
| supermarket_fqdn |  String | | |
| job_dispatch_version |  String |  default: 'v2' | |
| automate_user |  String |  default: 'admin' | |
| automate_password |  String | | |
| automate_enterprise |  String |  default: 'chef' | |
| chef_config_path |  String |  default: '/etc/chef/client.rb' | |
