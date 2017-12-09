require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    class ConfigSetCommand
      include ::Pier

      def initialize(workspace_config, argv, cwd)
        @workspace_config = workspace_config
        @argv = Array.new(argv)
        @cwd = cwd
      end

      def run
        options, name, value = parse_cli_args(@argv)

        case options[:visibility]
        when :workspace then
          @workspace_config.set(name, value, options[:priority])
          exit 0
        when :project then
          project_config = ProjectConfig.new(options[:project_name], @workspace_config)
          project_config.set(name, value, options[:priority])
          exit 0
        end
      end

      private

      def parse_cli_args(args)
        options, remaining_args, opt_parser = parse_cli_options(args)

        name = remaining_args.shift
        value = remaining_args.shift

        if name.to_s.empty? || value.to_s.empty?
          raise OptionParser::MissingArgument
        end

        if options[:visibility] === :unknown
          raise OptionParser::InvalidOption, '--workspace or --project is required'
          exit 1
        end

        [options, name, value]
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
        options = { visibility: :unknown, priority: :overrides }

        opt_parser = OptionParser.new do |opts|
          opts.banner = <<~BANNER
            Usage:
              moor config set [options] NAME VALUE

            Options:
          BANNER

          opts.summary_indent = ''

          opts.on('--workspace', 'Set the config option at the workspace level') do
            options[:visibility] = :workspace
          end

          opts.on('--project PROJECT_NAME', 'Set the config option at the project level') do |project_name|
            options[:visibility] = :project
            options[:project_name] = project_name
          end

          opts.on('--defaults', 'Set the config option in the defaults config instead of the overrides config') do
            options[:priority] = :defaults
          end
        end

        [options, opt_parser.parse(args), opt_parser]
      end
    end
  end
end
