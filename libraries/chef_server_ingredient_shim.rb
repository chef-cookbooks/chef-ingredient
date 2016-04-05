#
# Author:: Joshua Timberman <joshua@chef.io
# Copyright (c) 2014, Chef Software, Inc. <legal@chef.io>
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

require_relative './chef_ingredient_resource'
require_relative './chef_ingredient_provider'

class Chef
  class Provider
    class ChefServerIngredient < Chef::Provider::ChefIngredient
      provides :chef_server_ingredient
    end
  end
end

class Chef
  class Resource
    class ChefServerIngredient < Chef::Resource::ChefIngredient
      resource_name :chef_server_ingredient

      # Adding this for compatibility, it won't do anything since the
      # provider doesn't implement it
      attribute :repository, kind_of: String, default: ''
      # More compatibility for older versions of chef-server-ingredient
      attribute :master_token, kind_of: String
    end
  end
end
