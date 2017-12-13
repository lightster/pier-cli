require 'optparse'
require 'pier/command'
require 'pier/moor/config_command'
require 'pier/moor/install_command'
require 'pier/moor/proxy_command'
require 'pier/project_config'
require 'pier/workspace_config'
require 'shellwords'

module Pier
  class Moor
    include Command

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
      @cwd = cwd
    end

    def run
      args = @argv.dup
      command = args.shift

      if command == 'install'
        cmd = InstallCommand.new(@workspace_config, args)
        cmd.run
        exit 0
      elsif command == 'config'
        cmd = ConfigCommand.new(@workspace_config, args, @cwd)
        cmd.run
        exit 0
      elsif command == 'docker-compose'
        cmd = ProxyCommand.new('docker-compose', @workspace_config, args, @cwd)
        cmd.run
        exit 0
      elsif command == 'docker'
        cmd = ProxyCommand.new('docker', @workspace_config, args, @cwd)
        cmd.run
        exit 0
      elsif command == 'map-to-guest-workspace'
        map_to_guest_workspace(*args)
        exit 0
      elsif command == 'cd-dir'
        cd_dir(*args)
        exit 0
      end

      help
    end

    private

    def cd_dir(project = '')
      if !project.to_s.empty?
        project_dir = @workspace_config.project_dir(project)

        if ENV['PIER_HOST_ROOT']
          project_dir = project_dir.sub(
            @workspace_config.workspace_root,
            ENV['PIER_HOST_ROOT']
          )
        end

        print project_dir
      else
        print ENV['PIER_HOST_ROOT'] || @workspace_config.workspace_root
      end
    end

    def map_to_guest_workspace(host_workspace = '', pwd = '')
      mapped_dir = pwd.sub(host_workspace, @workspace_config.workspace_root)
      throw :outside_workspace if mapped_dir == pwd && !File.exist?(mapped_dir)
      puts mapped_dir
    end

    def help
      unless ENV['PIER_MOOR_BASH'].to_s.empty?
        cd_command = "\n  cd                Change directories to the root of a project"
      end

      puts <<~HELP
        Usage:
          moor COMMAND

        Available commands:#{cd_command}
          config            Set config option that all projects in workspace will have access to
          docker            Run a docker command
          docker-compose    Run a docker-compose command on the project found in the current working directory
          install           Install a project
          help              Output this help documentation
  HELP
      exit 1
    end
  end
end
