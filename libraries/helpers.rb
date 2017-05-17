#
# Author:: Joshua Timberman <joshua@chef.io>
# Copyright (c) 2014-2016, Chef Software, Inc. <legal@chef.io>
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
    def ingredient_config_file(product_name)
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
        install_gem_from_rubygems('mixlib-versioning', '~> 1.1')

        require 'mixlib/versioning'
        true
      end
    end

    #
    # Ensures mixlib-install gem is installed and loaded.
    #
    def ensure_mixlib_install_gem_installed!
      node.run_state[:mixlib_install_gem_installed] ||= begin # ~FC001
        if node['chef-ingredient']['mixlib-install']['git_ref']
          install_gem_from_source(
            'https://github.com/chef/mixlib-install.git',
            node['chef-ingredient']['mixlib-install']['git_ref'],
            'mixlib-install'
          )
        else
          install_gem_from_rubygems('mixlib-install', '~> 3.2')
        end

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

    #
    # Helper method to install a gem from source at compile time.
    #
    def install_gem_from_source(repo_url, git_ref, gem_name = nil)
      uri = URI.parse(repo_url)
      repo_basename = ::File.basename(uri.path)
      repo_name = repo_basename.match(/(?<name>.*)\.git/)[:name]
      gem_name ||= repo_name

      Chef::Log.debug("Building #{gem_name} gem from source")

      gem_clone_path = ::File.join(Chef::Config[:file_cache_path], repo_name)
      gem_file_path  = ::File.join(gem_clone_path, "#{gem_name}-*.gem")

      checkout_gem = Chef::Resource::Git.new(gem_clone_path, run_context)
      checkout_gem.repository(repo_url)
      checkout_gem.revision(git_ref)
      checkout_gem.run_action(:sync)

      ::FileUtils.rm_rf gem_file_path

      build_gem = Chef::Resource::Execute.new("build-#{gem_name}-gem", run_context)
      build_gem.cwd(gem_clone_path)
      build_gem.command(
        <<-EOH
#{::File.join(RbConfig::CONFIG['bindir'], 'gem')} build #{gem_name}.gemspec
        EOH
      )
      build_gem.run_action(:run) if checkout_gem.updated?

      install_gem = Chef::Resource::ChefGem.new(gem_name, run_context)
      install_gem_file_path = if windows?
                                Dir.glob(gem_file_path.tr('\\', '/')).first
                              else
                                Dir.glob(gem_file_path).first
                              end
      install_gem.source(install_gem_file_path)
      install_gem.run_action(:install) if build_gem.updated?
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
      version << '-1' unless version =~ /-1$/
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

    #
    # Creates a Mixlib::Install instance using the common attributes of
    # chef_ingredient resource that can be used for querying builds or
    # generating install scripts.
    #
    #
    def installer
      @installer ||= begin
        ensure_mixlib_install_gem_installed!

        options = {
          product_name: new_resource.product_name,
          channel: new_resource.channel,
          product_version: new_resource.version,
        }.tap do |opt|
          if new_resource.platform_version_compatibility_mode
            opt[:platform_version_compatibility_mode] = new_resource.platform_version_compatibility_mode
          end
          opt[:shell_type] = :ps1 if windows?
        end

        platform_details = {
          platform: platform_family_shortname,
          platform_version: truncate_platform_version(new_resource.platform_version, new_resource.platform),
          architecture: Mixlib::Install::Util.normalize_architecture(new_resource.architecture),
        }

        options.merge!(platform_details)

        Mixlib::Install.new(options)
      end
    end

    def prefix
      (platform_family?('windows') ? 'C:/Chef/' : '/etc/chef/')
    end

    def ensurekv(config, hash)
      hash.each do |k, v|
        if v.is_a?(Symbol)
          v = v.to_s
          str = v
        else
          str = "'#{v}'"
        end
        if config =~ /^ *#{v}.*$/
          config.sub(/^ *#{v}.*$/, "#{k} #{str}")
        else
          config << "\n#{k} #{str}"
        end
      end
      config
    end

    #
    # TODO: Imported from Omnibus::Metadata
    # Will be moved into a Mixlib Install module
    #

    #
    # Platform name to be used when creating metadata for the artifact.
    #
    # @return [String]
    #   the platform family short name
    #
    def platform_family_shortname
      if platform_family?('rhel')
        'el'
      elsif platform_family?('suse')
        'sles'
      else
        new_resource.platform
      end
    end

    #
    # TODO: Imported from Omnibus::Metadata
    # Will be moved into a Mixlib Install module
    #

    #
    # On certain platforms we don't care about the full MAJOR.MINOR.PATCH platform
    # version. This method will properly truncate the version down to a more human
    # friendly version. This version can also be thought of as a 'marketing'
    # version.
    #
    # @param [String] platform_version
    #   the platform version to truncate
    # @param [String] platform
    #   the platform shortname. this might be an Ohai-returned platform or
    #   platform family but it also might be a shortname like `el`
    #
    def truncate_platform_version(platform_version, platform)
      case platform
      when 'centos', 'debian', 'el', 'fedora', 'freebsd', 'omnios', 'pidora', 'raspbian', 'rhel', 'sles', 'suse', 'smartos', 'nexus', 'ios_xr' # ~FC024
        # Only want MAJOR (e.g. Debian 7, OmniOS r151006, SmartOS 20120809T221258Z)
        platform_version.split('.').first
      when 'aix', 'alpine', 'gentoo', 'mac_os_x', 'openbsd', 'slackware', 'solaris2', 'opensuse', 'ubuntu'
        # Only want MAJOR.MINOR (e.g. Mac OS X 10.9, Ubuntu 12.04)
        platform_version.split('.')[0..1].join('.')
      when 'arch'
        # Arch Linux does not have a platform_version ohai attribute, it is rolling release (lsb_release -r)
        'rolling'
      when 'windows'
        # Windows has this really awesome "feature", where their version numbers
        # internally do not match the "marketing" name.
        #
        # Definitively computing the Windows marketing name actually takes more
        # than the platform version. Take a look at the following file for the
        # details:
        #
        #   https://github.com/opscode/chef/blob/master/lib/chef/win32/version.rb
        #
        # As we don't need to be exact here the simple mapping below is based on:
        #
        #  http://www.jrsoftware.org/ishelp/index.php?topic=winvernotes
        #
        # Microsoft's version listing (more general than the above) is here:
        #
        # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724832(v=vs.85).aspx
        #
        case platform_version
        when '5.0.2195', '2000'   then '2000'
        when '5.1.2600', 'xp'     then 'xp'
        when '5.2.3790', '2003r2' then '2003r2'
        when '6.0.6001', '2008'   then '2008'
        when '6.1.7600', '7'      then '7'
        when '6.1.7601', '2008r2' then '2008r2'
        when '6.2.9200', '2012'   then '2012'
        # The following `when` will never match since Windows 8's platform
        # version is the same as Windows 2012. It's only here for completeness and
        # documentation.
        # when '6.2.9200', '8'      then '8'
        when /6\.3\.\d+/, '2012r2' then '2012r2'
        # The following `when` will never match since Windows 8.1's platform
        # version is the same as Windows 2012R2. It's only here for completeness
        # and documentation.
        # when /6\.3\.\d+/, '8.1' then '8.1'
        when /^10\.0/ then '10'
        else
          raise "Unknown Platform Version: #{platform} #{platform_version}"
        end
      else
        raise "Unknown Platform #{platform}"
      end
    end
  end
end
