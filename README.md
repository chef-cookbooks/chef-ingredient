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

Chef version 12.5.0 or higher, latest/current version is always recommended.

For local development, you need ChefDK 0.9.0 or newer.

### Platform

- Ubuntu 12.04, 14.04
- CentOS 6, 7

## Resources

### chef_server_ingredient

This is a backwards compatibility shim for the `chef_ingredient` resource.

This may be removed in a future version.

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

### omnibus_service

Manages a sub-service within the context of a Chef product package. For example the `rabbitmq` service that is run for the Chef Server.

#### Actions

This delegates to the ctl command the service management command specified in the action. Not all the service management commands are supported, however, as not all of them would make sense when used in a recipe. This resource is primarily used for sending or receiving notifications. See the example section.

#### Properties

- `ctl_command`: The "ctl" command, e.g. `chef-server-ctl`. This should be automatically detected by the library helper method `chef_ctl_command`, but may need to be specified if something changes, like a  new add-on is made available.
- `service_name`: (name attribute) The name of the service to manage. Specify this like `product_name/service`, for example, `chef-server/rabbitmq`.

### ingredient_config

Makes it easy to create update configuration files of each Chef product. It uses the default locations for each product.

#### Actions

- `render` - (default) Creates the configuration file using the options passed in via `add` action or `config` attribute of `chef_ingredient` resource.
- `add` - Adds the `config` attribute contents to the data collection.  Must run `:render` action to generate the file.

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

## License and Author

- Author: Joshua Timberman <joshua@chef.io>
- Author: Serdar Sutay <serdar@chef.io>
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
