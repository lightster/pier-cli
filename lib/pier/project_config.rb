require "pier/config"

module Pier
  class ProjectConfig
    def initialize(project_name, workspace_config)
      @workspace_config = workspace_config
      @project_dir = @workspace_config.project_dir(project_name)

      load_from_project
      init_system_defaults
    end

    def get(key)
      if @overrides.has?(key) then
        @overrides.get(key)
      elsif @defaults.has?(key) then
        @defaults.get(key)
      elsif @workspace_config.has?(key)
        @workspace_config.get(key)
      else
        @system_defaults.get(key)
      end
    end

    def set(key, value, priority = :overrides)
      if priority == :defaults then
        @defaults.set(key, value)
        @defaults.save_file(defaults_yaml)
      else
        @overrides.set(key, value)
        @overrides.save_file(overrides_yaml)
      end
    end

  private

    def init_system_defaults
      @system_defaults = Config.new
      @system_defaults.set('moor.install_options.configure', './configure docker')
      @system_defaults.set('moor.install_options.make', 'make install')
      @system_defaults.set('moor.install', default_install_commands)
    end

    def load_from_project
      @defaults = Config.new(file: defaults_yaml)
      @overrides = Config.new(file: overrides_yaml)
    end

    def defaults_yaml
      File.join(@project_dir, ".pier.defaults.yaml")
    end

    def overrides_yaml
      File.join(@project_dir, ".pier.overrides.yaml")
    end

    def default_install_commands
      install_commands = []

      configure_cmd = get('moor.install_options.configure')
      if File.exist?("#{@project_dir}/configure") && configure_cmd then
        install_commands.push(configure_cmd)
      end

      make_cmd = get('moor.install_options.make')
      if File.exist?("#{@project_dir}/Makefile") && make_cmd then
        install_commands.push(make_cmd)
      end

      install_commands
    end
  end
end
