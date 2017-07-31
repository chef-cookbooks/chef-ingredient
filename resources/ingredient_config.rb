#
# Author:: Joshua Timberman <joshua@chef.io
# Copyright:: 2015-2017, Chef Software, Inc. <legal@chef.io>
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

resource_name :ingredient_config

property :product_name, String, name_property: true
property :config, [String, NilClass]

action :render do
  target_config = ingredient_config_file(new_resource.product_name)
  return if target_config.nil?

  directory ::File.dirname(target_config) do
    recursive true
    action :create
  end

  file target_config do
    action :create
    sensitive new_resource.sensitive
    content get_config(new_resource.product_name)
  end
end

action :add do
  add_config(new_resource.product_name, config)
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
