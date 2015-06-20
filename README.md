# chef-ingredient Cookbook

This cookbook provides primitives - helpers and resources - to manage Chef Software, Inc.'s products and add-ons.

- Chef Server 12
- Chef Analytics
- Chef Delivery
- Supermarket

It will perform component installation and configuration. It provides no recipes. Instead, wrapper cookbooks should be created using the resources that this cookbook provides.

## Requirements

- apt
- yum

## Platform

- Ubuntu 10.04, 12.04, 14.04
- CentOS 6, 7

## Resources

### chef_server_ingredient

This is a backwards compatibility shim for the `chef_ingredient` resource.

### chef_ingredient

A "chef ingredient" is the core package itself, or products or add-on components published by Chef Software, Inc. This resource manages the installation, configuration, and running the `ctl reconfigure` of individual packages.

#### Actions

- `install` - (default) Configures the package repository and installs the specified package.
- `uninstall` - Uninstalls the specified package.
- `remove` - Alias for uninstall
- `reconfigure` - Performs the `ctl reconfigure` command for the package.

#### Properties
- `product_name`: (name attribute) The product name. See the `#product_matrix` method in `libraries/helpers.rb` for a list of valid product names. For example, `chef-server`, `analytics`, `delivery`, `manage`, etc.
- `package_name`: The name of the package in the repository. Should correspond to the published package names (`chef-server-core`, `opscode-manage`, etc).
- `ctl_command`: The "ctl" command, e.g., `chef-server-ctl`. This should be automatically detected by the library helper method `chef_ctl_command`, but may need to be specified if something changes, like a new add-on is made available.
- `options`: Options passed to the `package` resource used for installation.
- `version`: Package version, e.g., `12.0.4`. Do not use if specifying `package_source`. Default `nil`.
- `package_source`: Full path to a location where the package is located. If present, this file is used for installing the package. Default `nil`.
- `timeout`: The amount of time (in seconds) to wait to fetch the installer before timing out. Default: default timeout of the Chef package resource - `900` seconds.

### omnibus_service

Manages a sub-service within the context of a Chef product package. For example the `rabbitmq` service that is run for the Chef Server.

#### Actions

This delegates to the ctl command the service management command specified in the action. Not all the service management commands are supported, however, as not all of them would make sense when used in a recipe. This resource is primarily used for sending or receiving notifications. See the example section.

#### Properties

- `ctl_command`: The "ctl" command, e.g. `chef-server-ctl`. This should be automatically detected by the library helper method `chef_ctl_command`, but may need to be specified if something changes, like a  new add-on is made available.
- `service_name`: (name attribute) The name of the service to manage. Specify this like `product_name/service`, for example, `chef-server/rabbitmq`.

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

## License and Author

- Author: Joshua Timberman <joshua@chef.io>
- Copyright (C) 2014-2015, Chef Software Inc. <legal@chef.io>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
