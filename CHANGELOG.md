# chef-ingredient Cookbook CHANGELOG
This file is used to list changes made in each version of the chef-ingredient cookbook.

## 2.1.8 (2017-08-23)

- Fix permissions on automate keys and license.

## 2.1.7 (2017-08-11)

- Fix remove_users to use new_resource instead of current_resource.

## 2.1.6 (2017-08-10)

-  fix chef_org resource deprecation warnings
-  RHEL 5 and 6 package manager support (RHEL 5 is not officially supported)

## 2.1.5 (2017-07-31)

- Update the client resource to properly source the client.rb template
- Add a log warning if the default recipe is included on a run_list
- Added supported platforms to the metadata for Supermarket

## 2.1.4 (2017-07-27)

- Use default package provider on RHEL instead of RPM; fixes #181
- Resolve CHEF-19 deprecation warnings (#184)

## 2.1.3 (2017-06-29)
- Pin mixlib-install `~> 3.3`

## 2.1.2 (2017-06-03)
- Fix normalization of auto-detected and set architectures

## 2.1.1 (2017-05-22)
- Revert platform remapping and platform version truncation changes.
- `chef_ingredient` properties `platform`, `platform_version`, `architecture` default to auto-detected value when not set.

## 2.1.0 (2017-05-18)
- Add initial chef infrastructure resources and contributors from chef_stack project
- Add Ohai attributes as defaults to `chef_ingredient` resource properties `platform`, `platform_version`, and `architecture`
- Add platform remapping and platform version truncation fixes to align with Chef Software Inc's software distribution systems

## 2.0.5 (2017-04-24)

- [#155](https://github.com/chef-cookbooks/chef-ingredient/issues/155) Workaround chef_ingredient timeout property on Windows (windows_package timeout property currently broken in Chef)
- [#158](https://github.com/chef-cookbooks/chef-ingredient/issues/158) Remove #check_deprecated_properties logic (handled by mixlib-install)
- Allow chef_ingredient action :upgrade on Windows

## 2.0.4 (2017-04-13)

- Ensure mixlib-install `~> 3.2` is installed

## 2.0.3 (2017-04-13)

- Normalize architectures detected by ohai before mixlib-install validation

## 2.0.2 (2017-04-11)

- Update resources to support Chef 12.5 and 12.6

## 2.0.1 (2017-03-28)

- Update DefaultHandler and OmnitruckHandler to use a global constant lookup. In some environments, not doing so caused a naming conflict with the dynamically generated ChefIngredient DSL resource class.

## 2.0.0 (2017-03-24)

- Remove `chef_server_ingredient` resource shim
- Update mixlib-install to major version 3
 - `platform_version_compatibility_mode` property no longer has a default value
 - If no matching artifacts are found a `Mixlib::Install::Backend::ArtifactsNotFound` exception is raised instead a `RuntimeError`
- All resources have been converted to custom resources

## 1.1.0 (2017-03-01)

- Test with local delivery and not Rake
- Remove sensitive property for Chef 13 compatibility as this properly is provided by chef-client now for us by any resource and doesn't need to be defined
- Test in Travis CI with kitchen-dokken and convert tests to InSpec

## 1.0.1 (2017-02-22)

- Testing cleanup for Chef 13 compatibility and testing on the latest platforms

## 1.0.0 (2017-02-15)

- Require Chef 12.5+ and remove compat_resource dependency
- Use mixlib-install >= 2.1.12 - this brings in an important fix for the `delivery` -> `automate` package rename. See the [Discourse announcement](https://discourse.chef.io/t/chef-automate-install-package-renaming-in-0-7-14-available/10429/1) for details on the rename

## 0.21.4 (2017-02-13)
- Add properties to override the platform details of a `chef_ingredient` product to install

## 0.21.3 (2017-02-02)
- Add timeout to package resource created by configure_from_source_package

## 0.21.2 (2016-10-26)
- Fix issue when failed package installs using OmnitruckHandler would not raise a converge error on subsequent runs

## 0.21.1 (2016-10-25)
- Update SUSE platform to use DefaultHandler

## 0.21.0 (2016-09-26)
- Update mixlib-install to version 2.0 (PackageRouter support)

## 0.20.0 (2016-09-08)
- Remove extraneous converge_by that caused downloads to show as converged on every run
- Use compat_resource cookbook to add support for Chef 12.1-12.4
- Use apt_update resource vs. the apt cookbook in the test cookbook
- Update Travis CI testing to use our standard Rakefile and cookstyle for ruby linting.
- Fix chefspec / foodcritic / test kitchen failures
- Swap the Policyfile for a Berksfile
- Remove unnecessary action and default_action properties from the custom resources

# v0.19.0

- Remove delivery-cli examples and tests (we now shipit with ChefDK)
- Set version constraint to ~> 1.1 for installing mixlib-install from Rubygems

# v0.18.5

- [#106](https://github.com/chef-cookbooks/chef-ingredient/pull/106) Limit `remote_file` backups to 1
- [#110](https://github.com/chef-cookbooks/chef-ingredient/pull/110) Get rid of default: nil warnings

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
