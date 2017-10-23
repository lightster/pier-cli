require 'pier/config'
require 'pier/error/undetermined_project_error.rb'
require 'yaml'

module Pier
  class WorkspaceConfig
    attr_reader :codebase_dir
    attr_reader :clone_dir
    attr_reader :workspace_root

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
      if project.include?('/') && Dir.exist?(repo_dir) then
        return repo_dir
      end

      repo_pattern = "#{codebase_dir}/*/#{project}"
      matches = Dir.glob(repo_pattern)
      if matches.length == 1 then
        return matches[0]
      elsif matches.length >= 1
        error = "Multiple projects match the given project name:\n"
        matches.each do |path|
          match = path.sub("#{codebase_dir}/", '')
          error << " - #{match}\n"
        end
        error << "\nPlease use a full qualified project name."
        raise Error::UndeterminedProjectError, error
      end

      raise Error::UndeterminedProjectError, "No projects match '#{project}'"
    end

    def project_name_from_cwd(cwd)
      codebase_real = File.realpath(codebase_dir)
      cwd = File.realpath(cwd)

      org_name = ""
      project_name = ""
      loop do
        project_name = org_name
        org_name = File.basename(cwd)

        cwd = File.dirname(cwd)

        break if cwd == codebase_real || !cwd.include?(codebase_real)
      end

      if org_name.empty? || project_name.empty? then
        raise Error::UndeterminedProjectError, "Project could not be determined from CWD"
      end

      "#{org_name}/#{project_name}"
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
