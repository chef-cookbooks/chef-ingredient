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

class Chef
  class Provider
    class ChefServerIngredient < Chef::Provider::LWRPBase
      # FIXME: (jtimberman) remove this include when we switch to packagecloud_repo.
      require_relative './helpers'
      include ::PackageCloud::Helper

      use_inline_resources

      def whyrun_supported?
        true
      end

      def load_current_resource
        self.current_resource = Chef::Resource::ChefServerIngredient.new(new_resource.name)
        current_resource.package_name(new_resource.package_name)
        current_resource
      end

      action :install do
        case node['platform_family']
        when 'debian'
          package_type = 'deb'
        when 'rhel'
          package_type = 'rpm'
        end

        packagecloud_repo 'chef/stable' do
          type package_type
        end

        package new_resource.package_name do
          options new_resource.options
        end
      end

      action :uninstall do
        package new_resource.package_name do
          action :remove
        end
      end

      action :remove do
        action_uninstall
      end

      action :reconfigure do
        ctl_cmd = ctl_command
        execute "#{new_resource.package_name}-reconfigure" do
          command "#{ctl_cmd} reconfigure"
        end
      end

      private

      def ctl_command
        new_resource.ctl_command || chef_server_ctl_command(new_resource.package_name)
      end

      # we build on lucid by default, so if the codename isn't
      # supported, try lucid and hope for the best.
      def distro_codename
        supported_codenames = ['lucid', 'natty', 'precise']
        supported_codenames.include?(node['lsb']['codename']) ? node['lsb']['codename'] : 'lucid'
      end

      # The following methods contain code from
      # https://github.com/computology/packagecloud-cookbook/blob/master/providers/repo.rb
      #
      # FIXME: (jtimberman) Use the packagecloud_repo resource
      # instead, when it can either set the codename, or we publish
      # packages to "trusty"
      # def packagecloud_deb_repo
      #   repo_url = URI.join('https://packagecloud.io/', new_resource.repository + '/', node['platform'])
      #   repo_uri = read_token(repo_url).to_s
      #   codename =  distro_codename

      #   # packagecloud uses HTTPS, thus we need the HTTPS transport for apt.
      #   package 'apt-transport-https'

      #   apt_repository filename do
      #     uri repo_uri
      #     deb_src true
      #     distribution codename
      #     components ['main']
      #     keyserver 'pgp.mit.edu'
      #     key 'D59097AB'
      #   end
      # end

      def read_token(repo_url)
        return repo_url unless new_resource.master_token

        uri = URI.join(node['packagecloud']['base_url'], new_resource.repository + '/', 'tokens.text')
        uri.user     = new_resource.master_token
        uri.password = ''

        resp = post(uri, install_endpoint_params)

        Chef::Log.debug("#{new_resource.name} TOKEN = #{resp.body.chomp}")

        if platform_family?('rhel') && node['platform_version'].to_i == 5
          repo_url
        else
          repo_url.user     = resp.body.chomp
          repo_url.password = ''
          repo_url
        end
      end

      def install_endpoint_params
        dist = value_for_platform_family(
          'debian' => distro_codename,
          ['rhel', 'fedora'] => node['platform_version'],
        )

        {   :os   => node['platform'],
            :dist => dist,
            :name => node['fqdn'] }
      end

      def filename
        new_resource.repository.gsub(/[^0-9A-z.\-]/, '_')
      end
    end
  end
end
