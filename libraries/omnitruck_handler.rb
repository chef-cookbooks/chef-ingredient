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

module ChefIngredient
  module OmnitruckHandler
    def handle_install
      current_version = installer.current_version

      if new_resource.version == :latest
        # When we are installing :latest, we install only if there is no version right now
        if current_version.nil?
          configure_version(installer)
        else
          Chef::Log.debug("Found version #{current_version}, skipping installing :latest.")
        end
      else
        configure_version(installer) if new_resource.version != current_version
      end
    end

    def handle_upgrade
      configure_version(installer) if installer.upgrade_available?
    end

    def handle_uninstall
      fail 'Uninstalling a product is currently not supported.'
    end

    def configure_version(installer)
      install_command_resource = "install-#{new_resource.product_name}-#{new_resource.version}"

      file installer_script_path do
        content installer.install_command
        if windows?
          notifies :run, "powershell_script[#{install_command_resource}]", :immediately
        else
          notifies :run, "execute[#{install_command_resource}]", :immediately
        end
      end

      powershell_script install_command_resource do
        # We pass the install code directly, but still depend upon the file to
        # change before executing the install
        code installer.install_command
        action :nothing

        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end

      execute install_command_resource do
        command "sudo /bin/sh #{installer_script_path}"
        action :nothing

        if new_resource.product_name == 'chef'
          # We define this resource in ChefIngredientProvider
          notifies :run, 'ruby_block[stop chef run]', :immediately
        end
      end
    end

    def installer
      @installer ||= begin
        ensure_mixlib_install_gem_installed!

        options = {
          product_name: new_resource.product_name,
          channel: new_resource.channel,
          product_version: new_resource.version
        }.tap do |opt|
          opt[:shell_type] = :ps1 if windows?
        end

        Mixlib::Install.new(options)
      end
    end

    def installer_script_path
      @installer_script_path ||= begin
        installer_file = windows? ? 'installer.ps1' : 'installer.sh'
        File.join(Chef::Config[:file_cache_path], installer_file)
      end
    end
  end
end
