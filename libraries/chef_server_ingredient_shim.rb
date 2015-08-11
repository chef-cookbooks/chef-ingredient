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
    end
  end
end
