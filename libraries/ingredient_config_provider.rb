#
# Copyright (c) 2015, Chef Software, Inc. <legal@getchef.com>
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

class Chef
  class Provider
    class IngredientConfig < Chef::Provider::LWRPBase
      include ChefIngredientCookbook::Helpers

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :render do
        target_config = product_matrix[new_resource.product_name]['config-file']
        return if target_config.nil?

        directory ::File.dirname(target_config) do
          owner 'root'
          group 'root'
          mode '0755'
          not_if { ::File.exist?(::File.dirname(target_config)) }
          recursive true
          action :create
        end

        file target_config do
          owner 'root'
          group 'root'
          action :create
          sensitive new_resource.sensitive
          content get_config(new_resource.product_name)
        end
      end
    end
  end
end
