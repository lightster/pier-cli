require "pier/config"

module Pier
  class ProjectConfig
    def initialize(project_name, workspace_config)
      @workspace_config = workspace_config
      @project_dir = @workspace_config.project_dir(project_name)

      init_system_defaults
      load_from_project
    end

    def get(key)
      if @defaults.has?(key) then
        @defaults.get(key)
      else
        @system_defaults.get(key)
      end
    end

  private

    def init_system_defaults
      @system_defaults = Config.new
      @system_defaults.set('moor.install.configure', './configure docker')
      @system_defaults.set('moor.install.make', 'make install')
    end

    def load_from_project
      @defaults = Config.new
      @defaults.load_file!(defaults_yaml)
    end

    def defaults_yaml
      File.join(@project_dir, ".pier.yaml")
    end
  end
end
