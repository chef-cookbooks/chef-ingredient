#
# Author:: Joshua Timberman <joshua@chef.io>
# Copyright (c) 2014-2015, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module ChefIngredientCookbook
  module Helpers
    ########################################################################
    # Product details lookup helpers
    ########################################################################

    #
    # Returns the ctl-command to be used for omnibus_service resource.
    # Notice that we do not include version in our lookup since omnibus_service
    # is not aware of it.
    #
    def ctl_command_for_product(product)
      ensure_mixlib_install_gem_installed!

      PRODUCT_MATRIX.lookup(product).ctl_command
    end

    #
    # Returns the package name for a given product and version.
    #
    def ingredient_package_name
      ensure_mixlib_install_gem_installed!

      PRODUCT_MATRIX.lookup(new_resource.product_name, new_resource.version).package_name
    end

    #
    # Returns the ctl-command for a chef_ingredient resource
    #
    def ingredient_ctl_command
      ensure_mixlib_install_gem_installed!

      new_resource.ctl_command || PRODUCT_MATRIX.lookup(new_resource.product_name, new_resource.version).ctl_command
    end

    #
    # Returns the ctl-command for a chef_ingredient resource
    #
    def ingredient_config_file
      ensure_mixlib_install_gem_installed!

      PRODUCT_MATRIX.lookup(product_name).config_file
    end

    ########################################################################
    # Helpers installing gem prerequisites.
    ########################################################################

    #
    # Ensures mixlib-versioning gem is installed and loaded.
    #
    def ensure_mixlib_versioning_gem_installed!
      node.run_state[:mixlib_versioning_gem_installed] ||= begin # ~FC001
        install_gem_from_rubygems('mixlib-versioning', '1.1.0')

        require 'mixlib/versioning'
        true
      end
    end

    #
    # Ensures mixlib-install gem is installed and loaded.
    #
    def ensure_mixlib_install_gem_installed!
      node.run_state[:mixlib_install_gem_installed] ||= begin # ~FC001
        install_gem_from_rubygems('mixlib-install', '0.8.0.alpha.2')

        require 'mixlib/install'
        require 'mixlib/install/product'
        true
      end
    end

    #
    # Helper method to install a gem from rubygems at compile time.
    #
    def install_gem_from_rubygems(gem_name, gem_version)
      Chef::Log.debug("Installing #{gem_name} v#{gem_version} from Rubygems.org")
      chefgem = Chef::Resource::ChefGem.new(gem_name, run_context)
      chefgem.version(gem_version)
      chefgem.run_action(:install)
    end

    ########################################################################
    # Version helpers
    ########################################################################

    #
    # Returns if a given version is equivalent to :latest
    #
    def version_latest?(vers)
      vers == :latest || vers == '0.0.0' || vers == 'latest'
    end

    #
    # Returns true if the custom repo recipe was specified
    #
    def use_custom_repo_recipe?
      node['chef-ingredient'].attribute?('custom-repo-recipe')
    end

    #
    # Returns the custom setup recipe name
    #
    # When the user specifies this attribute chef-ingredient will not configure
    # our default packagecloud Chef repositories and instead it will include the
    # custom recipe. This will eliminate the hard dependency to the internet.
    #
    def custom_repo_recipe
      node['chef-ingredient']['custom-repo-recipe']
    end

    #
    # Returns the version string to use in package resource for all platforms.
    #
    def version_for_package_resource
      ensure_mixlib_versioning_gem_installed!

      version_string = if version_latest?(new_resource.version)
                         '0.0.0'
                       else
                         new_resource.version
                       end

      v = Mixlib::Versioning.parse(version_string)
      version = "#{v.major}.#{v.minor}.#{v.patch}"
      version << "~#{v.prerelease}" if v.prerelease? && !v.prerelease.match(/^\d$/)
      version << "+#{v.build}" if v.build?
      version << '-1' unless version.match(/-1$/)
      version << rhel_append_version if node['platform_family'] == 'rhel' &&
                                        !version.match(/#{rhel_append_version}$/)
      version
    end

    def rhel_major_version
      return node['platform_version'].to_i if node['platform_family'] == 'rhel'
      node['platform_version']
    end

    def rhel_append_version
      ".el#{rhel_major_version}"
    end

    ########################################################################
    # ingredient_config helpers
    ########################################################################

    #
    # Adds given config information for the given product to the run_state so
    # that it can be retrieved later.
    #
    def add_config(product, content)
      return if content.nil?

      # FC001: Use strings in preference to symbols to access node attributes
      # foodcritic thinks we are accessing a node attribute
      node.run_state[:ingredient_config_data] ||= {}              # ~FC001
      node.run_state[:ingredient_config_data][product] ||= ''     # ~FC001
      node.run_state[:ingredient_config_data][product] += content unless node.run_state[:ingredient_config_data][product].include?(content) # ~FC001
    end

    #
    # Returns the collected config information for the given product.
    #
    def get_config(product)
      # FC001: Use strings in preference to symbols to access node attributes
      # foodcritic thinks we are accessing a node attribute
      node.run_state[:ingredient_config_data] ||= {}          # ~FC001
      node.run_state[:ingredient_config_data][product] ||= '' # ~FC001
    end

    ########################################################################
    # misc helpers
    ########################################################################

    #
    # Returns true if a given fqdn resolves, false otherwise.
    #
    def fqdn_resolves?(fqdn)
      require 'resolv'
      Resolv.getaddress(fqdn)
      return true
    rescue Resolv::ResolvError, Resolv::ResolvTimeout
      false
    end
    module_function :fqdn_resolves?

    #
    # Declares a resource that will fail the chef run when signalled.
    #
    def declare_chef_run_stop_resource
      # We do not supply an option to turn off stopping the chef client run
      # after a version change. As the gems shipped with omnitruck artifacts
      # change, chef-client runs *WILL* occasionally break on minor version
      # updates of chef, so we *MUST* stop the chef-client run when its version
      # changes. The gems versions that chef-client started with will not
      # necessarily exist after an upgrade.
      ruby_block 'stop chef run' do
        action :nothing
        block do
          Chef::Application.fatal! 'Chef version has changed during the run. Stopping the current Chef run. Please run chef again.'
        end
      end
    end

    def windows?
      node['platform_family'] == 'windows'
    end
  end
end
