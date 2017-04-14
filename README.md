# chef-ingredient Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/chef-ingredient.svg?branch=master)](https://travis-ci.org/chef-cookbooks/chef-ingredient) [![Cookbook Version](https://img.shields.io/cookbook/v/chef-ingredient.svg)](https://supermarket.chef.io/cookbooks/chef-ingredient)

This cookbook provides primitives - helpers and resources - to manage Chef Software, Inc.'s products and add-ons including, but not limited to:

- Chef Server 12
- Chef Analytics
- Chef Delivery
- Chef Push
- Supermarket

It will perform component installation and configuration. It provides no recipes. Instead, wrapper cookbooks should be created using the resources that this cookbook provides.

## Maintainers and Support

This cookbook is maintained and supported by Chef's engineering services team. This cookbook runs through our internal Chef Delivery system, and changes must be approved by a member of engineering services.

## Requirements

### Platforms

- Ubuntu 12.04, 14.04, 16.04
- CentOS 6, 7

### Chef

- Chef 12.5+

### Cookbooks

- none

## Resources

### chef_ingredient

A "chef ingredient" is the core package itself, or products or add-on components published by Chef Software, Inc. This resource manages the installation, configuration, and running the `ctl reconfigure` of individual packages.

By default, `chef_ingredient` will install using the `packages.chef.io` stable repository depending on the platform. However, it can be configured to use a custom repository by setting the `node['chef-ingredient']['custom-repo-recipe']` attribute (nil by default).

#### Actions

- `install` - (default) Configures the package repository and installs the specified package.
- `uninstall` - Uninstalls the specified package.
- `remove` - Alias for uninstall
- `reconfigure` - Performs the `ctl reconfigure` command for the package.

#### Properties

- `product_name`: (name attribute) The product name. See the [PRODUCT_MATRIX.md](https://github.com/chef/mixlib-install/blob/master/PRODUCT_MATRIX.md). For example, `chef-server`, `analytics`, `delivery`, `manage`, etc.
- `config`: String content that will be added to the configuration file of the given product.
- `ctl_command`: The "ctl" command, e.g., `chef-server-ctl`. This should be automatically detected by the library helper method `chef_ctl_command`, but may need to be specified if something changes, like a new add-on is made available.
- `options`: Options passed to the `package` resource used for installation.
- `version`: Package version to install. Can be specified in various semver-alike ways: `12.0.4`, `12.0.3-rc.3`, and also `:latest`/`'latest'`. Do not use this property when specifying `package_source`. Default is `:latest`, which will install the latest package from the repository.
- `channel`: Channel to install the products from. It can be `:stable` (default), `:current` or `:unstable`.
- `package_source`: Full path to a location where the package is located. If present, this file is used for installing the package. Default `nil`.
- `timeout`: The amount of time (in seconds) to wait to fetch the installer before timing out. Default: default timeout of the Chef package resource - `900` seconds.
- `accept_license`: A boolean value that specifies if license should be accepted if it is asked for during `reconfigure`action. This option is applicable to only these products: manage, analytics, reporting and compliance. Default: `false`.
- `platform`: Override the auto-detected platform for which package to install.
- `platform_version`: Override the auto-detected platform version for which package to install.
- `architecture`: Override the auto-detected architecture for which package to install.
- `platform_version_compatibility_mode`: Find closest matching package when platform auto-detection does not find an exact package match in the repository

### omnibus_service

Manages a sub-service within the context of a Chef product package. For example the `rabbitmq` service that is run for the Chef Server.

#### Actions

This delegates to the ctl command the service management command specified in the action. Not all the service management commands are supported, however, as not all of them would make sense when used in a recipe. This resource is primarily used for sending or receiving notifications. See the example section.

#### Properties

- `ctl_command`: The "ctl" command, e.g. `chef-server-ctl`. This should be automatically detected by the library helper method `chef_ctl_command`, but may need to be specified if something changes, like a new add-on is made available.
- `service_name`: (name attribute) The name of the service to manage. Specify this like `product_name/service`, for example, `chef-server/rabbitmq`.

### ingredient_config

Makes it easy to create update configuration files of each Chef product. It uses the default locations for each product.

#### Actions

- `render` - (default) Creates the configuration file using the options passed in via `add` action or `config` attribute of `chef_ingredient` resource.
- `add` - Adds the `config` attribute contents to the data collection. Must run `:render` action to generate the file.

#### Properties

- `product_name`: (name attribute) The product name. See the [PRODUCT_MATRIX.md](https://github.com/chef/mixlib-install/blob/master/PRODUCT_MATRIX.md). For example, `chef-server`, `analytics`, `delivery`, `manage`, etc.
- `sensitive`: (default `false`) Set to mask the config contents in logs. Use when you config contains information like passwords or secrets.
- `config`: String content that will be added to the configuration file of the given product.

#### Examples

We may need to restart the RabbitMQ service on the Chef Server, for example when adding configuration for Chef Analytics.

```ruby
template '/etc/opscode/chef-server.rb' do
  notifies :restart, 'omnibus_service[chef-server-core/rabbitmq]'
end

omnibus_service 'chef-server-core/rabbitmq' do
  action :nothing
end
```

To install Chef Server using some custom configuration options:

```ruby
chef_ingredient "chef-server" do
  config <<-EOS
api_fqdn "#{node["fqdn"]}"
ip_version "ipv6"
notification_email "#{node["chef_admin"]}"
nginx["ssl_protocols"] = "TLSv1 TLSv1.1 TLSv1.2"
EOS
  action :install
end

ingredient_config "chef-server" do
  notifies :reconfigure, "chef_ingredient[chef-server]"
end
```

To install or upgrade lastest version of Chef Client on your nodes:

```ruby
chef_ingredient "chef" do
  action :upgrade
  version :latest
end
```

To install an addon of Chef Server from `:current` channel:

```ruby
chef_ingredient 'chef-server' do
  channel :stable
  action :install
end

chef_ingredient 'analytics' do
  channel :current
  action :install
end
```

## License & Authors

- Author: Joshua Timberman [joshua@chef.io](mailto:joshua@chef.io)
- Author: Serdar Sutay [serdar@chef.io](mailto:serdar@chef.io)
- Author: Patrick Wright [patrick@chef.io](mailto:patrick@chef.io)
- Copyright (C) 2014-2017, Chef Software Inc. [legal@chef.io](mailto:legal@chef.io)

```text

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
=======
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
