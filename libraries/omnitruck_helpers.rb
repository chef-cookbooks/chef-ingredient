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
  # The code in this module will eventually go into mixlib-install
  module OmnitruckHelpers
    include Helpers

    # TODO: This method should get product name as a parameter and find the
    # latest version for it.
    def current_version(product_name)
      unless %w(chef chefdk).include?(product_name)
        fail "Unknown product #{product_name}"
      end

      # TODO(serdar): This logic does not work for products other than
      # chef & chefdk since version-manifest is created under the
      # install directory which can be different than the product name (e.g.
      # chef-server -> /opt/opscode)
      JSON.parse("/opt/#{product_name}/version-manifest.json")['build_version']
    end

    # TODO: This method should get product name as a parameter and find the
    # latest version for it.
    def latest_available_version(_product_name)
      latest_metadata = omnitruck_get('/chef/metadata')

      # Extract the relative path from the response from metadata endpoint
      relative_path = latest_metadata['relpath']

      # Extract the version from the relative path
      # TODO: support more than Mac OS X
      relative_path.split('/').last[/^chef-(.*)\.dmg$/, 1]
    end

    # TODO: This method should get product name as a parameter and find the
    # latest version for it.
    def configure_version(version)
      # Install mixlib-install
      chef_gem "#{new_resource.product_name}-mixlib-install" do # ~FC009 foodcritic needs an update
        package_name 'mixlib-install'
        compile_time true
      end

      script "install-#{new_resource.product_name}-#{version}" do
        action :run
        code lazy {
          require 'mixlib/install'
          installer = Mixlib::Install.new(project: new_resource.product_name, version: version)
          installer.install_command
        }
        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end
    end

    # TODO: Currently mixlib-install does not provide this functionality.
    def uninstall_product(_product_name)
      # Install mixlib-install
      chef_gem "#{new_resource.product_name}-mixlib-install" do # ~FC009 foodcritic needs an update
        package_name 'mixlib-install'
        compile_time true
      end

      script "uninstall-#{new_resource.product_name}" do
        action :run
        code lazy {
          require 'mixlib/install'
          installer = Mixlib::Install.new(project: new_resource.product_name)
          installer.uninstall_command
        }
      end
    end

    private

    def omnitruck_get(path)
      parameters = platform_parameters.merge(channel_parameters(:current))
      endpoint = 'https://www.chef.io/'

      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      full_path = [path, URI.encode_www_form(parameters)].join('?')
      request = Net::HTTP::Get.new(full_path)
      request['Accept'] = 'application/json'
      res = http.request(request)

      # Raise if response is not 2XX
      res.value
      JSON.parse(res.body)
    end

    # Returns the platform parameters that omnitruck understands
    def platform_parameters
      # TODO: Support things other than Mac OS X 10.10
      {
        p: 'mac_os_x',
        pv: '10.10',
        m: 'x86_64'
      }
    end

    # Returns the channel parameters that omnitruck understands
    # TODO: This is not quite right. Currently omnitruck does not look at
    # builds that are posted to s3://opscode-omnibus-packages-current
    # so we need to change this.
    def channel_parameters(channel)
      if channel == :current
        {
          prerelease: true,
          nightlies: true
        }
      else
        {}
      end
    end
  end
end
