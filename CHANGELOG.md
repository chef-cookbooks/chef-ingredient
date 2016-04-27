# v0.18.4

- Add `platform_version_compatibility_mode` property to `chef_ingredient` which makes chef-ingredient select packages built for earlier version of a platform during install when a package does not exist for the current platform version.

# v0.18.3

- Add `accept_license` property to `chef_ingredient` which can accept license for Chef products when applicable.

# v0.18.2

- Set version constraint to ~> 1.0 for installing mixlib-install from Rubygems

# v0.18.1

- Bump mixlib-install version to 1.0.6 so unstable channel artifacts won't include metadata.json files.

# v0.18.0

- [#85](https://github.com/chef-cookbooks/chef-ingredient/pull/85) Ability to support unstable channel for all products / platforms.
- [#90](https://github.com/chef-cookbooks/chef-ingredient/pull/90) Use packages from packages.chef.io instead of package cloud & remove packagecloud repository setup.
- [#91](https://github.com/chef-cookbooks/chef-ingredient/pull/91) Deprecate chef-ha, chef-marketplace, chef-sync, push-client, push-server in favor of ha, marketplace, sync, push-jobs-client, push-jobs-server.

# v0.17.0

- [#77](https://github.com/chef-cookbooks/chef-ingredient/pull/77) Enable installation of chef and chefdk from unstable
- [#82](https://github.com/chef-cookbooks/chef-ingredient/pull/82) Set `--force-yes` for older Debian/Ubuntu

# v0.16.0

- [#62](https://github.com/chef-cookbooks/chef-ingredient/issues/62) Do not assume connection to the internet, allow custom recipe for a local repository
- [#75](https://github.com/chef-cookbooks/chef-ingredient/pull/75) omnitruck handler windows implementation

# v0.15.0

- [#66](https://github.com/chef-cookbooks/chef-ingredient/pull/66) Fix push job client and server naming
- [#68](https://github.com/chef-cookbooks/chef-ingredient/pull/68) Use mixlib-install while installing / upgrading packages from omnitruck
- [#71](https://github.com/chef-cookbooks/chef-ingredient/pull/71) Convert `omnibus_service` and `ingredient_config` to "12.5 [custom resources](https://docs.chef.io/custom_resources.html)"
- [#73](https://github.com/chef-cookbooks/chef-ingredient/pull/73) Use PRODUCT_MATRIX from mixlib-install

# v0.14.0

- [#58](https://github.com/chef-cookbooks/chef-ingredient/pull/58) Add Chef Compliance product


# v0.13.1

- [#57](https://github.com/chef-cookbooks/chef-ingredient/pull/57) Content accumulator guard

# v0.13.0

- [#56](https://github.com/chef-cookbooks/chef-ingredient/pull/56) Uncomment `use_inline_resources`, this is required for the providers to work properly
- [#55](https://github.com/chef-cookbooks/chef-ingredient/pull/55) Remove unit tests for specifically the custom resources
- [#54](https://github.com/chef-cookbooks/chef-ingredient/pull/54) Clarify maintainer/support in the README

# v0.12.1

- [#53](https://github.com/chef-cookbooks/chef-ingredient/pull/53) Relax version constraints

# v0.12.0

- Refactor `chef_ingredient` and prepare to handle install/upgrade from omnitruck
- Add channel property to `chef_ingredient`
- Removed installed state property
- Use `product_name` instead of `package_name`
- Add not if to skip `ingredient_config` render if `config` property isn't used

# v0.11.3

- Remove `resource_name` from Provider because `:facepalm:`

# v0.11.2

- Add `repository` and `master_token` properties to `chef_server_ingredient` shim for compatibility

# v0.11.1

- [#37](https://github.com/chef-cookbooks/chef-ingredient/issues/37) use `define_matchers` for ChefSpec

# v0.11.0

- [#35](https://github.com/chef-cookbooks/chef-ingredient/issues/35) Add `fqdn_resolves?` method for `chef-server` cookbook.

# v0.10.2
- Add `:add` action to `ingredient_config`

# v0.10.1

- [#30](https://github.com/chef-cookbooks/chef-ingredient/issues/30) Supermarket doesn't use supermarket.rb for configuration, it's supermarket.json

# v0.10.0

- [#23](https://github.com/chef-cookbooks/chef-ingredient/pull/23) Add Chef Marketplace
- [#29](https://github.com/chef-cookbooks/chef-ingredient/pull/29) Fix RSpec and noisy warnings

# v0.9.1

- [#26](https://github.com/chef-cookbooks/chef-ingredient/issues/26) Remove mode, owner, and group properties from `ingredient_config`'s resources to prevent resource updates after running ctl commands that manage those file permissions.

# v0.9.0

- Add sensitive property to `ingredient_config`
- Use recipe DSL to set resource name

# v0.8.1

- Update PRODUCT_MATRIX.md with correct updated Chef Push product names (push-server, push-client). The code was updated but not the document.

# v0.8.0

- [#7](https://github.com/chef-cookbooks/chef-ingredient/issues/7) Add `ingredient_config` resource
- [#10](https://github.com/chef-cookbooks/chef-ingredient/pull/10) Add upgrade action for `chef_ingredient`
- Test cleanup, various rubocop fixes

# v0.7.0

- [#3](https://github.com/chef-cookbooks/chef-ingredient/issues/3) Allow :latest as a version
- Removes the `package_name` property from the `chef_ingredient` resource, long live `product_name`

# v0.6.0

**Breaking changes** This version is backwards-incompatible with previous versions. We're still sub-1.0, but those who wish to use the `chef_server_ingredient` resource really should pin to version 0.5.0.

- [#1](https://github.com/chef-cookbooks/chef-ingredient/issues/1) Use product names instead of package names.

# v0.5.0

- Major refactor and rename. It's fine, this is a new cookbook!

# v0.4.0 (2015-06-11)

- Add timeout attribute to `chef_server_ingredient`
- Use `declare_resource` DSL method to select local package resource
- Allow specifying the repository name for the packagecloud repo

# v0.3.2 (2015-04-15)

- adding proxy support for packagecloud

# v0.3.1 (2015-04-09)

- Various refactoring and cleanup

# v0.3.0

- Add ctl command for supermarket

# v0.2.0

- Add reconfigure property to ingredient resource

# v0.1.0

- Release this cookbook to Supermarket

# v0.0.2

- #4: define the installed attribute
- #1, #2, use packagecloud cookbook

# v0.0.1

- Initial release
