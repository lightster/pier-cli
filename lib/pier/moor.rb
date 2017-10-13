require 'optparse'
require 'pier/project_config'
require 'pier/workspace_config'

module Pier
  class Moor
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
    end

    def run()
      args = @argv.dup
      command = args.shift

      if command == "install" then
        install(*args)
        exit 0
      elsif command == "config" then
        config(args)
        exit 0
      end

      puts <<HELP
Usage:
  moor COMMAND

Available commands:
  install    Install a project
  config     Set config option that all projects in workspace will have access to
  help       Output this help documentation
HELP
      exit 0
    end

    def install(repo = "")
      abort "A repo name must be provided" if repo.to_s.empty?

      codebase_dir = @workspace_config.codebase_dir
      clone_dir = @workspace_config.clone_dir
      repo_dir = "#{codebase_dir}/#{repo}"

      if !Dir.exist?(repo_dir) then
        runShellProcOrDie %W(
          git clone git@github.com:#{repo}.git #{clone_dir}/#{repo}
        )
      end

      project_config = ProjectConfig.new(repo, @workspace_config)

      install_commands = project_config.get('moor.install') || []
      install_commands = install_commands.values if install_commands.is_a?(Hash)

      install_commands.each do |command|
        runShellProcOrDie %Q(cd "#{repo_dir}" && #{command})
      end if install_commands.is_a?(Array)
    end

    def config(args)
      args = args.dup
      command = args.shift

      case command
      when "set" then
        config_set(args)
        exit 0
      when "get" then
        config_get(args)
        exit 0
      end

      puts <<HELP
Usage:
  moor config COMMAND

Available commands:
  set        Set a config option
  get        Get a config option
HELP
      exit 1
    end

    def config_set(args)
      options = {visibility: :unknown, priority: :overrides}

      opt_parser = OptionParser.new do |opts|
        opts.banner = <<BANNER
Usage:
  moor config set [options] NAME VALUE

Options:
BANNER

        opts.summary_indent = ''

        opts.on("--workspace", "Set the config option at the workspace level") do
          options[:visibility] = :workspace
        end

        opts.on("--project PROJECT_NAME", "Set the config option at the project level") do |project_name|
          options[:visibility] = :project
          options[:project_name] = project_name
        end

        opts.on("--defaults", "Set the config option in the defaults config instead of the overrides config") do
          options[:priority] = :defaults
        end
      end

      parsed_args = opt_parser.parse(args)

      name = parsed_args.shift
      value = parsed_args.shift

      if !name.to_s.empty? && !value.to_s.empty? then
        case options[:visibility]
        when :workspace then
          @workspace_config.set(name, value, options[:priority])
          exit 0
        when :project then
          project_config = ProjectConfig.new(options[:project_name], @workspace_config)
          project_config.set(name, value, options[:priority])
          exit 0
        end

        raise OptionParser::InvalidOption, '--workspace or --project is required'
        exit 1
      end
    rescue OptionParser::InvalidOption => exception
      puts exception.message.capitalize
      puts
      puts opt_parser
    else
      puts opt_parser
      exit 1
    end

    def config_get(args)
      options = {visibility: :unknown, priority: :hierarchy}

      opt_parser = OptionParser.new do |opts|
        opts.banner = <<BANNER
Usage:
  moor config get [options] NAME

Options:
BANNER

        opts.summary_indent = ''

        opts.on("--workspace", "Get the config option from the workspace level") do
          options[:visibility] = :workspace
        end

        opts.on("--project PROJECT_NAME", "Get the config option from the project level") do |project_name|
          options[:visibility] = :project
          options[:project_name] = project_name
        end

        opts.on("--defaults", "Get the config option from the defaults config") do
          options[:priority] = :defaults
        end

        opts.on("--overrides", "Get the config option from the overrides config") do
          options[:priority] = :overrides
        end
      end

      parsed_args = opt_parser.parse(args)

      name = parsed_args.shift

      if !name.to_s.empty? then
        case options[:visibility]
        when :workspace then
          puts @workspace_config.get_from(name, options[:priority])
          exit 0
        when :project then
          project_config = ProjectConfig.new(options[:project_name], @workspace_config)
          puts project_config.get_from(name, options[:priority])
          exit 0
        end

        raise OptionParser::InvalidOption, '--workspace or --project is required'
        exit 1
      end
    rescue OptionParser::InvalidOption => exception
      puts exception.message.capitalize
      puts
      puts opt_parser
    else
      puts opt_parser
      exit 1
    end
  end
end
