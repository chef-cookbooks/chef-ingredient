#
# Author:: Serdar Sutay <serdar@chef.io>
# Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>
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

require_relative './omnitruck_helpers'

module ChefIngredient
  module OmnitruckHandler
    include ChefIngredientCookbook::OmnitruckHelpers

    def handle_install
      verify_supported_products!

      current_version = current_version(new_resource.product_name)
      latest_version = latest_available_version(new_resource.product_name, new_resource.channel)

      if new_resource.version == :latest
        # When we are installing :latest, we install only if there is no version right now
        if current_version.nil?
          configure_version(latest_version)
        else
          Chef::Log.debug("Found version #{current_version}, skipping installing :latest.")
        end
      else
        if new_resource.version != current_version
          configure_version(new_resource.version)
        end
      end
    end

    def handle_upgrade
      verify_supported_products!

      current_version = current_version(new_resource.product_name)
      latest_version = latest_available_version(new_resource.product_name, new_resource.channel)

      candidate_version = new_resource.version == :latest ? latest_version : new_resource.version

      # MIXLIB-INSTALL: Use mixlib-install to do the > check on versions.
      if current_version.nil? || candidate_version > current_version
        configure_version(candidate_version)
      end
    end

    def handle_uninstall
      verify_supported_products!

      uninstall_product(new_resource.product_name)
    end
  end
end
