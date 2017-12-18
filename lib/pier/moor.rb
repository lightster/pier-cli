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
        cmd = MapToGuestWorkspaceCommand.new(@workspace_config, args)
        cmd.run
        exit 0
      elsif command == 'cd-dir'
        cmd = CdDirCommand.new(@workspace_config, args, @cwd)
        cmd.run
        exit 0
      end

      cmd = HelpCommand.new
      cmd.run
    end
  end
end
