class Chef
  class Resource
    class ChefServerIngredient < Chef::Resource::LWRPBase
      self.resource_name = 'chef_server_ingredient'

      actions :install, :uninstall, :remove, :reconfigure
      default_action :install
      state_attrs :installed

      attribute :package_name, kind_of: String, name_attribute: true
      # Attributes to install package from local file
      attribute :package_source, kind_of: String, default: nil
      # Attributes for reconfigure step
      attribute :ctl_command, kind_of: String
      # Attributes for package
      attribute :options, kind_of: String
      # Attributes for packagecloud/apt repository
      attribute :master_token, kind_of: String
      attribute :repository, kind_of: String, default: 'chef/stable'
      attribute :version, kind_of: String, default: nil
      attribute :installed, kind_of: [TrueClass, FalseClass, NilClass], default: false
      attribute :reconfigure, kind_of: [TrueClass, FalseClass], default: false
      attribute :timeout, kind_of: [Integer, String, NilClass], default: nil
    end
  end
end
