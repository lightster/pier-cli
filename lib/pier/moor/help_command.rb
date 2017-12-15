module Pier
  class Moor
    class HelpCommand
      def run
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
end
