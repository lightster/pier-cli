require 'optparse'
require 'pier/moor/config_get_command'
require 'pier/moor/config_set_command'

module Pier
  class Moor
    class ConfigCommand
      include ::Pier

      def initialize(workspace_config, argv, cwd)
        @workspace_config = workspace_config
        @argv = Array.new(argv)
        @cwd = cwd
      end

      def run
        args = @argv.dup
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
    end
  end
end
