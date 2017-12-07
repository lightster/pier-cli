require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    class InstallCommand
      include ::Pier

      def initialize(workspace_config, argv)
        @workspace_config = workspace_config
        @argv = Array.new(argv)
      end

      def run
        options, repo = parse_cli_args(@argv)

        codebase_dir = @workspace_config.codebase_dir
        clone_dir = @workspace_config.clone_dir
        repo_dir = "#{codebase_dir}/#{repo}"

        unless Dir.exist?(repo_dir)
          run_shell_proc! %W[
            git clone git@github.com:#{repo}.git #{clone_dir}/#{repo}
          ]
        end

        branch = options[:branch]
        unless branch.to_s.empty?
          run_shell_proc! %(cd #{clone_dir}/#{repo} && git checkout #{branch})
        end

        project_config = ProjectConfig.new(repo, @workspace_config)

        unless options[:config].empty?
          options[:config].each_pair do |key, value|
            project_config.set(key, value, :overrides)
          end
        end

        install_commands = project_config.get('moor.install') || []
        install_commands = install_commands.values if install_commands.is_a?(Hash)

        Dir.chdir(repo_dir) do
          if install_commands.is_a?(Array)
            install_commands.each do |command|
              command = command.call if command.respond_to?(:call)

              run_shell_proc!(command) if command
            end
          end
        end
      end

      private

      def parse_cli_args(args)
        options, remaining_args, opt_parser = parse_cli_options(args)

        repo = remaining_args.shift
        if repo.to_s.empty?
          raise OptionParser::InvalidOption, 'A repo name must be provided'
        end

        [options, repo]
      rescue OptionParser::InvalidOption => exception
        puts exception.message.capitalize
        puts
        puts opt_parser
        exit 1
      end

      def parse_cli_options(args)
        options = { branch: nil, config: {} }

        opt_parser = OptionParser.new do |opts|
          opts.banner = <<~BANNER
            Usage:
            moor install [options] REPO_NAME

            Options:
  BANNER

          opts.summary_indent = ''

          opts.on('--branch BRANCH_NAME', 'Set the branch name to checkout after cloning project') do |branch_name|
            options[:branch] = branch_name
          end

          opts.on('--config CONFIG', 'Set a config option at the project level after cloning project') do |config_pair|
            key, valid, value = config_pair.partition('=')

            if valid.empty?
              raise OptionParser::InvalidOption,
                    "Config options should be in key=value pairs. '#{config_pair}' does not contain an equals sign."
            end

            options[:config][key] = value
          end
        end

        [options, opt_parser.parse(args), opt_parser]
      end
    end
  end
end
