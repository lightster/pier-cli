require 'optparse'
require 'pier/command'
require 'pier/moor/cd_dir_command'
require 'pier/moor/config_command'
require 'pier/moor/help_command'
require 'pier/moor/install_command'
require 'pier/moor/map_to_guest_workspace_command'
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

      commands = {
        "install": lambda {
          return InstallCommand.new(@workspace_config, args)
        },
        "config": lambda {
          return ConfigCommand.new(@workspace_config, args, @cwd)
        },
        "docker-compose": lambda {
          return ProxyCommand.new('docker-compose', @workspace_config, args, @cwd)
        },
        "docker": lambda {
          return ProxyCommand.new('docker', @workspace_config, args, @cwd)
        },
        "map-to-guest-workspace": lambda {
          return MapToGuestWorkspaceCommand.new(@workspace_config, args)
        },
        "cd-dir": lambda {
          return CdDirCommand.new(@workspace_config, args, @cwd)
        },
        "help": lambda {
          HelpCommand.new
        },
      }

      if command && !commands.key?(command.to_sym)
        puts "Invalid command: #{command}"
        command = "help"
      end

      command = :help if !command

      cmd = commands[command.to_sym].call
      cmd.run
    end
  end
end
