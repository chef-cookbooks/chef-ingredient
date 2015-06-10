#
# Author:: Joshua Timberman <joshua@getchef.com
# Copyright (c) 2014, Chef Software, Inc. <legal@getchef.com>
#
# Portions from https://github.com/computology/packagecloud-cookbook:
# Copyright (c) 2014, Computology, LLC.
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

require 'uri'
require 'pathname'

module ChefServerIngredientsCookbook
  module Helpers
    # FIXME: (jtimberman) make this data we can change / use without
    # having to update the library code (e.g., if we create new
    # add-ons, or change any of these in the future).
    def chef_server_ctl_command(pkg)
      ctl_cmds = {
        'chef-server-core' => 'chef-server-ctl',
        'opscode-manage' => 'opscode-manage-ctl',
        'opscode-push-jobs-server' => 'opscode-push-jobs-server-ctl',
        'opscode-reporting' => 'opscode-reporting-ctl',
        'opscode-analytics' => 'opscode-analytics-ctl',
        'chef-sync' => 'chef-sync-ctl',
        'supermarket' => 'supermarket-ctl'
      }
      ctl_cmds[pkg]
    end

    def local_package_resource
      return :dpkg_package if node['platform_family'] == 'debian'
      return :rpm_package if node['platform_family'] == 'rhel'
      :package # fallback if there's no platform match
    end

    def ctl_command
      new_resource.ctl_command || chef_server_ctl_command(new_resource.package_name)
    end

    def reconfigure
      ctl_cmd = ctl_command
      execute "#{new_resource.package_name}-reconfigure" do
        command "#{ctl_cmd} reconfigure"
      end
    end
  end
end

# This is the Proxy Implementation to pull down packages from packagecloud
# currently there is a PR to the packagecloud community cookbook:
# FIXME: (afiune) https://github.com/computology/packagecloud-cookbook/pull/14
module PackageCloud
  module Helper

    def get(uri, params)
      uri.query = URI.encode_www_form(params)
      req       = Net::HTTP::Get.new(uri.request_uri)

      http_request(uri, req)
    end

    def post(uri, params)
      req           = Net::HTTP::Post.new(uri.request_uri)
      req.form_data = params

      req.basic_auth uri.user, uri.password if uri.user

      http_request(uri, req)
    end

    def http_request(uri, request)
      if proxy_url = Chef::Config['https_proxy'] || Chef::Config['http_proxy'] || ENV['https_proxy'] || ENV['http_proxy']
        proxy_uri = URI.parse(proxy_url)
        proxy     = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)

        response = proxy.start(uri.host, :use_ssl => true) do |http|
          http.request(request)
        end
      else
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true

        response = http.start { |h|  h.request(request) }
      end

      raise response.inspect unless response.is_a? Net::HTTPSuccess
      response
    end

  end
end
