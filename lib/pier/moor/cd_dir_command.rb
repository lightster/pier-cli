require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    class CdDirCommand
      def initialize(workspace_config, args, cwd)
        @workspace_config = workspace_config
        @args = Array.new(args)
        @cwd = cwd
      end

      def run
        project = @args.shift

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
    end
  end
end
