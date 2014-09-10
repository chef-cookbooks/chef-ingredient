if defined?(ChefSpec)
  def install_chef_server_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_ingredient, :install, pkg)
  end

  def uninstall_chef_server_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_ingredient, :uninstall, pkg)
  end

  def remove_chef_server_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_ingredient, :remove, pkg)
  end

  def reconfigure_chef_server_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_ingredient, :reconfigure, pkg)
  end
end
