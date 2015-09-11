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
