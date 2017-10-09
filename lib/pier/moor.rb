require "pier/project_config"
require 'pier/workspace_config'

module Pier
  class Moor
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
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

      project_config = ProjectConfig.new(repo, @workspace_config)

      install_commands = project_config.get('moor.install') || []
      install_commands = install_commands.values if install_commands.is_a?(Hash)

      install_commands.each do |command|
        runShellProcOrDie %Q(cd "#{repo_dir}" && #{command})
      end if install_commands.is_a?(Array)
    end

    def config(*args)
      command = args.shift

      if command == "set" then
        config_set(*args)
      end

      puts <<HELP
Usage:
  moor config COMMAND

Available commands:
  set        Set a config option
HELP
      exit 1
    end

    def config_set(name = "", value = "")
      if !name.to_s.empty? && !value.to_s.empty? then
        @workspace_config.set(name, value)
        exit 0
      end

      puts <<HELP
Usage:
  moor config set NAME VALUE
HELP
      exit 1
    end
  end
end
