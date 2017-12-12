require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    class ConfigGetCommand
      def initialize(workspace_config, argv, cwd)
        @workspace_config = workspace_config
        @argv = Array.new(argv)
        @cwd = cwd
      end

      def run
        options, name = parse_cli_args(@argv)

        case options[:visibility]
        when :workspace then
          puts @workspace_config.get_from(name, options[:priority])
          exit 0
        when :project then
          project_config = ProjectConfig.new(options[:project_name], @workspace_config)
          puts project_config.get_from(name, options[:priority])
          exit 0
        else
          begin
            project_name = @workspace_config.project_name_from_cwd(@cwd)
            project_config = ProjectConfig.new(project_name, @workspace_config)
            puts project_config.get_from(name, options[:priority])
            exit 0
          rescue Error::UndeterminedProjectError
            raise OptionParser::InvalidOption, '--workspace or --project is required, or command must be ran from inside project directory'
            exit 1
          end
        end
      end

      private

      def parse_cli_args(args)
        options, remaining_args, opt_parser = parse_cli_options(args)

        name = remaining_args.shift
        if name.to_s.empty?
          raise OptionParser::MissingArgument
        end

        [options, name]
      rescue OptionParser::InvalidOption => exception
        puts exception.message.capitalize
        puts
        puts opt_parser
        exit 1
      rescue OptionParser::MissingArgument
        puts opt_parser
        exit 1
      end

      def parse_cli_options(args)
        options = { visibility: :unknown, priority: :hierarchy }

        opt_parser = OptionParser.new do |opts|
          opts.banner = <<~BANNER
            Usage:
              moor config get [options] NAME

            Options:
          BANNER

          opts.summary_indent = ''

          opts.on('--workspace', 'Get the config option from the workspace level') do
            options[:visibility] = :workspace
          end

          opts.on('--project PROJECT_NAME', 'Get the config option from the project level') do |project_name|
            options[:visibility] = :project
            options[:project_name] = project_name
          end

          opts.on('--defaults', 'Get the config option from the defaults config') do
            options[:priority] = :defaults
          end

          opts.on('--overrides', 'Get the config option from the overrides config') do
            options[:priority] = :overrides
          end
        end

        [options, opt_parser.parse(args), opt_parser]
      end
    end
  end
end
