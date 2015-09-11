#
# Author:: Joshua Timberman <joshua@chef.io
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
    class ChefIngredient < Chef::Resource::LWRPBase
      resource_name :chef_ingredient

      actions :install, :uninstall, :remove, :reconfigure, :upgrade
      default_action :install
      state_attrs :installed

      attribute :product_name, kind_of: String, name_attribute: true
      attribute :installed, kind_of: [TrueClass, FalseClass, NilClass], default: false
      attribute :reconfigure, kind_of: [TrueClass, FalseClass], default: false
      attribute :config, kind_of: String, default: nil

      # Attribute to install package from local file
      attribute :package_source, kind_of: String, default: nil

      # Attributes for reconfigure step
      attribute :ctl_command, kind_of: String

      # Attributes for package
      attribute :options, kind_of: String
      attribute :version, kind_of: [String, Symbol], default: :latest
      attribute :timeout, kind_of: [Integer, String, NilClass], default: nil
    end
  end
end
