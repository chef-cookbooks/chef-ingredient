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

module ChefServerIngredient
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
        'chef-sync' => 'chef-sync-ctl'
      }
      ctl_cmds[pkg]
    end
  end
end

Chef::Recipe.send(:include, ChefServerIngredient::Helpers)
Chef::Resource.send(:include, ChefServerIngredient::Helpers)
Chef::Provider.send(:include, ChefServerIngredient::Helpers)

# From https://github.com/computology/packagecloud-cookbook/blob/master/libraries/helper.rb
# FIXME: (jtimberman) Use the packagecloud_repo resource
# instead, when it can either set the codename, or we publish
# packages to "trusty"
module PackageCloud
  module Helper
    require 'net/https'

    def get(uri, params)
      uri.query     = URI.encode_www_form(params)
      req           = Net::HTTP::Get.new(uri.request_uri)

      req.basic_auth uri.user, uri.password if uri.user

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      resp = http.start { |h| h.request(req) }

      case resp
      when Net::HTTPSuccess
        resp
      else
        raise resp.inspect
      end
    end

    def post(uri, params)
      req           = Net::HTTP::Post.new(uri.request_uri)
      req.form_data = params

      req.basic_auth uri.user, uri.password if uri.user

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      resp = http.start { |h|  h.request(req) }

      case resp
      when Net::HTTPSuccess
        resp
      else
        raise resp.inspect
      end
    end
  end
end
