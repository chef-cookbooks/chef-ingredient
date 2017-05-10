if defined?(ChefSpec)
  %i(chef_ingredient omnibus_service ingredient_config).each do |resource|
    ChefSpec.define_matcher resource
  end

  def install_chef_ingredient(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :install, name)
  end

  def upgrade_chef_ingredient(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :upgrade, name)
  end

  def uninstall_chef_ingredient(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :uninstall, name)
  end

  def remove_chef_ingredient(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :remove, name)
  end

  def reconfigure_chef_ingredient(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_ingredient, :reconfigure, name)
  end

  def restart_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :restart, name)
  end

  def start_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :start, name)
  end

  def stop_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :stop, name)
  end

  def hup_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :hup, name)
  end

  def int_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :int, name)
  end

  def kill_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :kill, name)
  end

  def graceful_kill_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :graceful_kill, name)
  end

  def once_kill_omnibus_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_service, :once, name)
  end

  def render_ingredient_config(name)
    ChefSpec::Matchers::ResourceMatcher.new(:ingredient_config, :render, name)
  end

  def add_ingredient_config(name)
    ChefSpec::Matchers::ResourceMatcher.new(:ingredient_config, :add, name)
  end

  def create_chef_automate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_automate, :create, name)
  end

  def create_backend_cluster(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_backend, :create, name)
  end

  def join_backend_cluster(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_backend, :join, name)
  end

  def create_chef_org(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_org, :create, name)
  end

  def delete_chef_org(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_org, :delete, name)
  end

  def create_chef_user(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_user, :create, name)
  end

  def delete_chef_user(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_user, :delete, name)
  end

  def install_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :install, name)
  end

  def register_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :register, name)
  end

  def run_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :run, name)
  end

  def create_chef_file(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_file, :create, name)
  end

  def create_chef_server(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server, :create, name)
  end

  def create_chef_supermarket(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_supermarket, :create, name)
  end

  def create_build_node(name)
    ChefSpec::Matchers::ResourceMatcher.new(:workflow_builder, :create, name)
  end
end
