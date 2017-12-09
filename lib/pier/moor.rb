require 'optparse'
require 'pier/moor/config_get_command'
require 'pier/moor/config_set_command'
require 'pier/moor/install_command'
require 'pier/project_config'
require 'pier/workspace_config'
require 'shellwords'

module Pier
  class Moor
    include ::Pier

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
        config(args)
        exit 0
      elsif command == 'docker-compose'
        proxy_command('docker-compose', args)
        exit 0
      elsif command == 'docker'
        proxy_command('docker', args)
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

    def config(args)
      args = args.dup
      command = args.shift

      case command
      when 'set' then
        cmd = ConfigSetCommand.new(@workspace_config, args, @cwd)
        cmd.run
        exit 0
      when 'get' then
        cmd = ConfigGetCommand.new(@workspace_config, args, @cwd)
        cmd.run
        exit 0
      end

      puts <<~HELP
        Usage:
          moor config COMMAND

        Available commands:
          set        Set a config option
          get        Get a config option
HELP
      exit 1
    end

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

    def proxy_command(command, args)
      cwd = @cwd

      begin
        project_name = @workspace_config.project_name_from_cwd(@cwd)
        codebase_dir = @workspace_config.codebase_dir
        cwd = "#{codebase_dir}/#{project_name}"
      rescue Error::UndeterminedProjectError
      end

      Dir.chdir(cwd) do
        escaped = args.map(&:shellescape)
        escaped.unshift(command)

        run_shell_proc!(escaped.join(' '))
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
