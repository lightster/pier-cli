require 'shellwords'

module Pier
  class Pier
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new(cwd)
    end

    def run()
      args = Array.new(@argv)
      command = args.shift

      if command == "help" || command.to_s.empty? then
        projects = available_projects({shortened: true})
        puts <<HELP
Usage:
  pier PROJECT

Available projects:
  #{projects.join("\n  ")}
HELP
        exit 0
      end

      run_project_command(command, args)
    end

  private

    def run_project_command(project, commands)
      project_dir = @workspace_config.project_dir(project)

      if File.exist?("#{project_dir}/Makefile") then
        escaped = commands.map do |command|
          command.shellescape
        end
        full_command = escaped.join " "

        runShellProcOrDie %Q(cd '#{project_dir}' && make #{full_command})
      end
    rescue Error::UndeterminedProjectError => exception
      STDERR.puts exception.message
      exit 1
    end

    def available_projects(options = {})
      codebase_dir = @workspace_config.codebase_dir

      repo_pattern = "#{codebase_dir}/*/*"
      files = Dir.glob(repo_pattern).select do |file|
        if file == '.' || file == '..' || !File.directory?("#{file}/.git") then
          false
        else
          File.directory? file
        end
      end.map do |file|
        namespace = File.basename(File.dirname(file))
        repo = File.basename(file)

        File.join(namespace, repo)
      end

      return files if !options[:shortened]

      project_counts = files.each_with_object(Hash.new(0)) do |fq_project, counts|
        project = File.basename(fq_project)

        counts[project] += 1
      end

      files.map do |fq_project|
        project = File.basename(fq_project)
        if project_counts[project] == 1 then
          project
        else
          fq_project
        end
      end.sort
    end
  end
end
