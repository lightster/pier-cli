require 'pier/config'

module Pier
  class ProjectConfig
    def initialize(project_name, workspace_config)
      @workspace_config = workspace_config
      @project_name = project_name
    end

    def get(key)
      if overrides.has?(key)
        overrides.get(key)
      elsif defaults.has?(key)
        defaults.get(key)
      elsif @workspace_config.has?(key)
        @workspace_config.get(key)
      else
        system_defaults.get(key)
      end
    end

    def get_from(key, priority = nil)
      if priority == :overrides
        overrides.get(key)
      elsif priority == :defaults
        defaults.get(key)
      elsif priority == :hierarchy
        get(key)
      else
        raise ArgumentError, 'priority should be: :overrides, :defaults, :hierarchy'
      end
    end

    def set(key, value, priority = :overrides)
      if priority == :defaults
        defaults.set(key, value)
        defaults.save_file(defaults_yaml)
      else
        overrides.set(key, value)
        overrides.save_file(overrides_yaml)
      end
    end

    private

    def generate_system_defaults
      system_defaults = Config.new
      system_defaults.set('pier.run.command', 'make')
      system_defaults.set('moor.install_options.configure', './configure pier')
      system_defaults.set('moor.install_options.make', 'make install')
      system_defaults.set('moor.install', default_install_commands)

      system_defaults
    end

    def system_defaults
      @system_defaults ||= generate_system_defaults
    end

    def defaults
      @defaults ||= Config.new(file: defaults_yaml)
    end

    def overrides
      @overrides ||= Config.new(file: overrides_yaml)
    end

    def defaults_yaml
      File.join(project_dir, '.pier.defaults.yaml')
    end

    def overrides_yaml
      File.join(project_dir, '.pier.overrides.yaml')
    end

    def project_dir
      @project_dir ||= @workspace_config.project_dir(@project_name)
    end

    def default_install_commands
      install_commands = []

      install_commands.push proc {
        configure_cmd = get('moor.install_options.configure')
        if File.exist?("#{project_dir}/configure") && configure_cmd
          configure_cmd
        end
      }

      install_commands.push proc {
        make_cmd = get('moor.install_options.make')
        make_cmd if File.exist?("#{project_dir}/Makefile") && make_cmd
      }

      install_commands
    end
  end
end
