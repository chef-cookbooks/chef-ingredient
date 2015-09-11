#
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
class Chef
  class Resource
    class IngredientConfig < Chef::Resource::LWRPBase
      resource_name :ingredient_config

      actions :render, :add
      default_action :render

      attribute :product_name, kind_of: String, name_attribute: true
      attribute :sensitive, kind_of: [TrueClass, FalseClass], default: false
      attribute :config, kind_of: String, default: nil
    end
  end
end
