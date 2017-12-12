require 'shellwords'
require 'pier/command'

module Pier
  class Pier
    include Command

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
    end

    def run
      args = Array.new(@argv)
      command = args.shift

      if command == 'help' || command.to_s.empty?
        projects = available_projects(shortened: true)
        puts <<~HELP
          Usage:
            pier PROJECT

          Available projects:
            #{projects.join("\n  ")}
HELP
        exit 1
      end

      run_project_command(command, args)
    end

    private

    def run_project_command(project_name, args)
      project_dir = @workspace_config.project_dir(project_name)
      project_config = ProjectConfig.new(project_name, @workspace_config)

      base_command = project_config.get('pier.run.command')

      escaped = args.map(&:shellescape)
      escaped_args = escaped.join ' '
      full_command = "#{base_command} #{escaped_args}"

      run_shell_proc! %(cd '#{project_dir}' && #{full_command})
    rescue Error::UndeterminedProjectError => exception
      STDERR.puts exception.message
      exit 1
    end

    def available_projects(options = {})
      codebase_dir = @workspace_config.codebase_dir

      repo_pattern = "#{codebase_dir}/*/*"
      files = Dir.glob(repo_pattern).select do |file|
        if file == '.' || file == '..' || !File.directory?("#{file}/.git")
          false
        else
          File.directory? file
        end
      end.map do |file|
        namespace = File.basename(File.dirname(file))
        repo = File.basename(file)

        File.join(namespace, repo)
      end

      return files unless options[:shortened]

      project_counts = files.each_with_object(Hash.new(0)) do |fq_project, counts|
        project = File.basename(fq_project)

        counts[project] += 1
      end

      files.map do |fq_project|
        project = File.basename(fq_project)
        if project_counts[project] == 1
          project
        else
          fq_project
        end
      end.sort
    end
  end
end
