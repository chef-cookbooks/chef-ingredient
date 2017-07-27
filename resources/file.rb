#
# Author:: Nathan Cerny <ncerny@chef.io>
#
# Cookbook:: chef-ingredient
# Resource:: file
#
# Copyright:: 2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# rubocop:disable Lint/ParenthesesAsGroupedExpression

resource_name 'chef_file'
default_action :create

property :filename, String, name_property: true
property :source, String
property :user, String, default: 'root'
property :group, String, default: 'root'
property :mode, String, default: '0600'

load_current_value do
  current_value_does_not_exist! unless ::File.exist?(filename)
end

action :create do
  new_resource.source = (property_is_set?(:source) ? new_resource.source : "cookbook_file://#{new_resource.filename}")
  if new_resource.source.start_with?('cookbook_file://')
    src = new_resource.source.split('://')[1].split('::')

    cookbook_file new_resource.filename do
      source src[-1]
      cookbook (src.length == 2 ? src[0] : cookbook_name)
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
    end
  elsif new_resource.source =~ %r{^[a-zA-Z]*://.*}
    remote_file new_resource.filename do
      source new_resource.source
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
    end
  else
    file new_resource.filename do
      content new_resource.source
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
    end
  end
end

action_class.class_eval do
  include ChefIngredientCookbook::Helpers
end
