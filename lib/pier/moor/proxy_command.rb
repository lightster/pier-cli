require 'pier/command'
require 'shellwords'

module Pier
  class Moor
    class ProxyCommand
      include Command

      def initialize(command, workspace_config, args, cwd)
        @command = command
        @workspace_config = workspace_config
        @args = Array.new(args)
        @cwd = cwd
      end

      def run
        cwd = @cwd

        begin
          project_name = @workspace_config.project_name_from_cwd(@cwd)
          codebase_dir = @workspace_config.codebase_dir
          cwd = "#{codebase_dir}/#{project_name}"
        rescue Error::UndeterminedProjectError
        end

        Dir.chdir(cwd) do
          escaped = @args.map(&:shellescape)
          escaped.unshift(@command)

          run_shell_proc!(escaped.join(' '))
        end
      end
    end
  end
end
