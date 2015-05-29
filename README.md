chef-server-ingredient Cookbook
===============================

This cookbook is used by CHEF in Hosted Chef to manage Chef Server and
Chef Server add-on component installation and reconfiguration. It
provides no useful recipes. Instead, wrapper cookbooks should be
created using the resource that this cookbook contains.

As of initial release, the cookbook borrows from, but does not use
[Packagecloud's](http://packagecloud.io) cookbook to set up the
repository where we publish Chef Server packages.

Requirements
------------
- packagecloud

Platform
--------
- Ubuntu 10.04, 12.04, 14.04
- CentOS 6

Resources
---------
### chef_server_ingredient

A "chef server ingredient" is the core package itself, or any add-on
component published by CHEF. This resource manages the installation
and running the `ctl reconfigure` of individual packages.

#### Actions

- `install` - (default) Configures the packagecloud apt repository and
  installs the specified package.  
- `uninstall` - Uninstalls the specified package.
- `remove` - Alias for uninstall
- `reconfigure` - Performs the `ctl reconfigure` command for the package.

#### Properties
- `package_name`: (name attribute) The name of the package. Should
  correspond to the published package names (chef-server-core,
  opscode-manage, etc).  
- `ctl_command`: The "ctl" command, e.g., `chef-server-ctl`. This
  should be automatically detected by the library helper method
  `chef_server_ctl_command`, but may need to be specified if something
  changes, like a new add-on is made available.
- `options`: Options passed to the `package` resource used for
  installation.  
- `master_token`: Used for packagecloud private repositories.
- `repository`: Name of the repository where the packages are located
  on packagecloud. Default `chef/stable`.  
- `version`: Package version, e.g., `12.0.0-rc.6-1`. Do not use if
  specifying `package_source`. Default `nil`.  
- `package_source`: Full path to a location where the package is
  located. If present, this file is used for installing the package.
  Default `nil`.  
- `timeout`: The amount of time (in seconds) to wait to fetch the installer
  before timing out. Default: default timeout of the Chef package resource.

License and Author
------------------
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
