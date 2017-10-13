require "pier/config"
require 'yaml'

module Pier
  class WorkspaceConfig
    attr_reader :codebase_dir
    attr_reader :clone_dir

    def initialize(cwd)
      locate_workspace_root(cwd)
      load_from_workspace
    end

    def get(key)
      if @overrides.has?(key) then
        @overrides.get(key)
      else
        @defaults.get(key)
      end
    end

    def get_from(key, priority = nil)
      if priority == :overrides then
        @overrides.get(key)
      elsif priority == :defaults then
        @defaults.get(key)
      elsif priority == :hierarchy then
        get(key)
      else
        raise ArgumentError, 'priority should be: :overrides, :defaults, :hierarchy'
      end
    end

    def has?(key)
      return @overrides.has?(key) || @defaults.has?(key)
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

    def project_dir(project)
      repo_dir = "#{codebase_dir}/#{project}"
      if project.include?('/') && Dir.exists?(repo_dir) then
        return repo_dir
      end

      repo_pattern = "#{codebase_dir}/*/#{project}"
      matches = Dir.glob(repo_pattern)
      if matches.length == 1 then
        return matches[0]
      elsif matches.length >= 1
        STDERR.puts "Multiple projects match the given project name:"
        matches.each do |path|
          match = path.sub!("#{codebase_dir}/", '')
          STDERR.puts " - #{match}"
        end
        STDERR.puts "\nPlease use a full qualified project name."
        exit 1
      end

      STDERR.puts "No projects match '#{project}'"
      exit 1
    end

  private

    def load_from_workspace()
      @defaults = Config.new(file: defaults_yaml)
      @overrides = Config.new(file: overrides_yaml)

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

    def defaults_yaml
      File.join(@dot_pier, "config.defaults.yaml")
    end

    def overrides_yaml
      File.join(@dot_pier, "config.overrides.yaml")
    end

    def locate_workspace_root(cwd)
      dir = cwd
      prev_dir = nil

      while prev_dir != "/"
        dot_pier = File.join(dir, ".pier")

        if File.directory?(dot_pier) then
          @workspace_root = dir
          @dot_pier = dot_pier
          return
        end

        prev_dir = dir
        dir = File.dirname(dir)
      end

      throw :outside_workspace
    end
  end
end
