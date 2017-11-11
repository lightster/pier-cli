require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class InstallCommand
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
    end

    def run()
      options, parsed_args = parse_cli_args(@argv)

      repo = parsed_args.shift
      if repo.to_s.empty? then
        raise OptionParser::InvalidOption, 'A repo name must be provided'
      end

      codebase_dir = @workspace_config.codebase_dir
      clone_dir = @workspace_config.clone_dir
      repo_dir = "#{codebase_dir}/#{repo}"

      if !Dir.exist?(repo_dir) then
        runShellProcOrDie %Q(
          git clone git@github.com:#{repo}.git #{clone_dir}/#{repo}
        )
      end

      branch = options[:branch]
      if !branch.to_s.empty? then
        runShellProcOrDie %Q(cd #{clone_dir}/#{repo} && git checkout #{branch})
      end

      project_config = ProjectConfig.new(repo, @workspace_config)

      unless options[:config].empty? then
        options[:config].each_pair do |key, value|
          project_config.set(key, value, :overrides)
        end
      end

      install_commands = project_config.get('moor.install') || []
      install_commands = install_commands.values if install_commands.is_a?(Hash)

      Dir.chdir(repo_dir) do
        install_commands.each do |command|
          if command.respond_to?(:call) then
            command = command.call
          end

          if command then
            runShellProcOrDie(command)
          end
        end if install_commands.is_a?(Array)
      end
    rescue OptionParser::InvalidOption => exception
      puts exception.message.capitalize
      puts
      puts opt_parser
    end

  private

    def parse_cli_args(args)
      options = {branch: nil, config: {}}

      opt_parser = OptionParser.new do |opts|
        opts.banner = <<BANNER
Usage:
moor install [options] REPO_NAME

Options:
BANNER

        opts.summary_indent = ''

        opts.on("--branch BRANCH_NAME", "Set the branch name to checkout after cloning project") do |branch_name|
          options[:branch] = branch_name
        end

        opts.on("--config CONFIG", "Set a config option at the project level after cloning project") do |config_pair|
          key, valid, value = config_pair.partition('=')

          if valid.empty? then
            raise OptionParser::InvalidOption,
              "Config options should be in key=value pairs. '#{config_pair}' does not contain an equals sign."
          end

          options[:config][key] = value
        end
      end

      parsed_args = opt_parser.parse(args)

      return options, parsed_args
    end
  end
end
