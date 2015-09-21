if defined?(ChefSpec)
  %i(chef_ingredient chef_server_ingredient omnibus_service ingredient_config).each do |resource|
    ChefSpec.define_matcher resource
  end

  def install_chef_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :install, pkg)
  end

  def upgrade_chef_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :upgrade, pkg)
  end

  def uninstall_chef_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :uninstall, pkg)
  end

  def remove_chef_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :remove, pkg)
  end

  def reconfigure_chef_ingredient(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :reconfigure, pkg)
  end

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

  def restart_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :restart, pkg)
  end

  def start_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :start, pkg)
  end

  def stop_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :stop, pkg)
  end

  def hup_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :hup, pkg)
  end

  def int_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :int, pkg)
  end

  def kill_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :kill, pkg)
  end

  def graceful_kill_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :graceful_kill, pkg)
  end

  def once_kill_omnibus_service(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :once, pkg)
  end

  def render_ingredient_config(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:ingredient_config, :render, pkg)
  end

  def add_ingredient_config(pkg)
    ChefSpec::Matchers::ResourceMatcher.new(:ingredient_config, :add, pkg)
  end
end
