require "pier/config"
require 'yaml'

module Pier
  class WorkspaceConfig
    include Config

    attr_reader :codebase_dir
    attr_reader :clone_dir

    def initialize(cwd)
      locate_workspace_root(cwd)
      load_from_workspace
    end

    def save
      File.write(@config_yaml, get_all.to_yaml)
    end

  private

    def load_from_workspace()
      if File.exists?(@config_yaml)
        config = YAML.load_file(@config_yaml)
      end

      if !config.is_a?(Hash) then
        config = {}
      end

      init_config(config)

      @codebase_dir = "codebase"
      if has?("codebase_dir") then
        @codebase_dir = get("codebase_dir")
      end
      @codebase_dir = File.absolute_path(@codebase_dir, @workspace_root)

      @clone_dir = @codebase_dir
      if has?("codebase_dir") then
        @clone_dir = File.absolute_path(get("clone_dir"), @workspace_root)
      end
    end

    def locate_workspace_root(cwd)
      dir = cwd
      prev_dir = nil

      while prev_dir != "/"
        dot_pier = File.join(dir, ".pier")

        if File.directory?(dot_pier) then
          @workspace_root = dir
          @dot_pier = dot_pier
          @config_yaml = File.join(@dot_pier, "config")
          return
        end

        prev_dir = dir
        dir = File.dirname(dir)
      end

      throw :outside_workspace
    end
  end
end
