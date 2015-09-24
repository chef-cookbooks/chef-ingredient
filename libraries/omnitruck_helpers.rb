#
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

require_relative './helpers'
require 'net/http'
require 'json'

module ChefIngredientCookbook
  ##############################################################################
  # THE CODE IN THIS MODULE WILL EVENTUALLY BE MOVED TO mixlib-install
  ##############################################################################
  module OmnitruckHelpers
    include Helpers

    # Raises an exception if the given product name is not supported.
    # Currently only chef and chefdk installation is supported via omnitruck.
    def verify_supported_products!
      unless %w(chef chefdk).include?(new_resource.product_name)
        fail "Unknown product #{product_name}. chef_ingredient can only install chef & chefdk on this platform."
      end
    end

    def current_version(product_name)
      # Note that this logic does not work for products other than
      # chef & chefdk since version-manifest is created under the
      # install directory which can be different than the product name. E.g.
      # chef-server -> /opt/opscode
      version_manifest_file = "/opt/#{product_name}/version-manifest.json"
      if File.exist? version_manifest_file
        JSON.parse(File.read(version_manifest_file))['build_version']
      end
    end

    def latest_available_version(product_name, channel)
      latest_metadata = omnitruck_metadata(channel, product_name)

      # Extract the relative path from the response from metadata endpoint
      relative_path = latest_metadata['relpath']

      # MIXLIB-INSTALL:
      # Currently we support only Mac here. In the near future we will add
      # version information to the metadata endpoint of omnitruck so we will
      # not need to do these things.
      relative_path.split('/').last[/^#{product_name}-(.*)\.dmg$/, 1]
    end

    def configure_version(version)
      # Install mixlib-install
      chef_gem "#{new_resource.product_name}-mixlib-install" do # ~FC009 foodcritic needs an update
        package_name 'mixlib-install'
        compile_time true
      end

      bash "install-#{new_resource.product_name}-#{version}" do
        action :run
        code lazy {
          require 'mixlib/install'

          installer = if new_resource.product_name == 'chefdk'
                        Mixlib::Install.new(version, false, install_flags: '-p chefdk')
                      else # chef
                        Mixlib::Install.new(version)
                      end

          Chef::Log.info installer.install_command
          installer.install_command
        }
        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end
    end

    def uninstall_product(_product_name)
      # MIXLIB-INSTALL: Currently mixlib-install does not provide this functionality.
      fail 'Uninstalling a product is currently not supported.'
      # Install mixlib-install
      # chef_gem "#{new_resource.product_name}-mixlib-install" do # ~FC009 foodcritic needs an update
      #   package_name 'mixlib-install'
      #   compile_time true
      # end
      #
      # script "uninstall-#{new_resource.product_name}" do
      #   action :run
      #   code lazy {
      #     require 'mixlib/install'
      #     installer = Mixlib::Install.new(project: new_resource.product_name)
      #     installer.uninstall_command
      #   }
      # end
    end

    private

    def omnitruck_metadata(channel, product_name)
      endpoint = 'https://omnitruck.chef.io/'

      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      full_path = ["/#{channel}/metadata-#{product_name}", URI.encode_www_form(platform_parameters)].join('?')
      request = Net::HTTP::Get.new(full_path)
      request['Accept'] = 'application/json'
      res = http.request(request)

      # Raise if response is not 2XX
      res.value
      JSON.parse(res.body)
    end

    # Returns the platform parameters that omnitruck understands
    # MIXLIB-INSTALL:
    # Currently we only support Mac 10.10. In the near future we will add
    # version information to the metadata endpoint of omnitruck and use
    # mixlib-install to do this resolution.
    def platform_parameters
      {
        p: 'mac_os_x',
        pv: '10.10',
        m: 'x86_64'
      }
    end
  end
end
