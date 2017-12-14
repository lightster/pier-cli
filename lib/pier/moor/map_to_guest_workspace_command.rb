require 'optparse'
require 'pier/command'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    class MapToGuestWorkspaceCommand
      include Command

      def initialize(workspace_config, args)
        @workspace_config = workspace_config
        @args = Array.new(args)
      end

      def run
        host_workspace, pwd = @args

        mapped_dir = pwd.sub(host_workspace, @workspace_config.workspace_root)
        throw :outside_workspace if mapped_dir == pwd && !File.exist?(mapped_dir)
        puts mapped_dir
      end
    end
  end
end
