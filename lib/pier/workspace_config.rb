require "pier/config"
require 'yaml'

module Pier
  class WorkspaceConfig
    attr_reader :codebase_dir
    attr_reader :clone_dir

    def initialize(config)
      if config.is_a?(String)
        load_from_workspace(config)
      end
    end

  private

    def load_from_workspace(cwd)
      dot_pier = locate_workspace_root(cwd)
      root = File.dirname(dot_pier)
      config_file = File.join(dot_pier, "config")

      if File.exists?(config_file)
        @config = YAML.load_file(config_file)
      end

      if !@config.is_a?(Hash) then
        @config = {}
      end

      @codebase_dir = "codebase"
      if @config.key?("codebase_dir") then
        @codebase_dir = @config["codebase_dir"]
      end
      @codebase_dir = File.absolute_path(@codebase_dir, root)

      @clone_dir = @codebase_dir
      if @config.key?("codebase_dir") then
        @clone_dir = File.absolute_path(@config["clone_dir"], root)
      end
    end

    def locate_workspace_root(cwd)
      dir = cwd
      prev_dir = nil

      while prev_dir != "/"
        dot_pier = File.join(dir, ".pier")

        return dot_pier if File.directory?(dot_pier)

        prev_dir = dir
        dir = File.dirname(dir)
      end

      throw :outside_workspace
    end
  end
end
