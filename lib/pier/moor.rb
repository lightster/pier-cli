require "pier/project_config"
require 'pier/workspace_config'

module Pier
  class Moor
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
      @project_config = ProjectConfig.new
    end

    def run()
      args = Array.new(@argv)
      command = args.shift

      if command == "install" then
        install(*args)
        exit 0
      elsif command == "config" then
        config(*args)
        exit 0
      end

      puts <<HELP
Usage:
  moor COMMAND

Available commands:
  install    Install a project
  config     Set config option that all projects in workspace will have access to
  help       Output this help documentation
HELP
      exit 0
    end

    def install(repo = "")
      abort "A repo name must be provided" if repo.to_s.empty?

      codebase_dir = @workspace_config.codebase_dir
      clone_dir = @workspace_config.clone_dir
      repo_dir = "#{codebase_dir}/#{repo}"

      if !Dir.exist?(repo_dir) then
        runShellProcOrDie %W(
          git clone git@github.com:#{repo}.git #{clone_dir}/#{repo}
        )
      end

      if File.exist?("#{repo_dir}/configure") then
        configure_cmd = @project_config.get('moor.install.configure')
        runShellProcOrDie %Q(cd "#{repo_dir}" && #{configure_cmd})
      end

      if File.exist?("#{repo_dir}/Makefile") then
        make_cmd = @project_config.get('moor.install.make')
        runShellProcOrDie %Q(cd '#{repo_dir}' && #{make_cmd})
      end
    end

    def config(name, value)
      @workspace_config.set(name, value)
      @workspace_config.save
    end
  end
end
