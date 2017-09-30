require 'shellwords'

module Pier
  class Pier
    include ::Pier

    def initialize(cwd, argv)
      @argv = Array.new(argv)
      @workspace_config = WorkspaceConfig.new.load_from_workspace(cwd)
    end

    def run()
      args = Array.new(@argv)
      command = args.shift

      if command == "help" || command.to_s.empty? then
        projects = getAvailableProjects({shortened: true})
        puts <<HELP
Usage:
  pier PROJECT

Available projects:
  #{projects.join("\n  ")}
HELP
        exit 0
      end

      runProjectCommand(command, args)
    end

    def runProjectCommand(project, commands)
      project_dir = getProjectDir(project)

      if File.exist?("#{project_dir}/Makefile") then
        escaped = commands.map do |command|
          command.shellescape
        end
        full_command = escaped.join " "

        runShellProcOrDie %Q(cd '#{project_dir}' && make #{full_command})
      end
    end

    def getAvailableProjects(options = {})
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

  private

    def getProjectDir(project)
      codebase_dir = @workspace_config.codebase_dir

      repo_dir = "#{codebase_dir}/#{project}"
      if project.include?('/') && Dir.exists?(repo_dir) then
        return repo_dir
      end

      repo_pattern = "#{codebase_dir}/*/#{project}"
      matches = Dir.glob(repo_pattern)
      if matches.length == 1 then
        return matches[0]
      elsif matches.length >= 1
        STDERR.puts "Multiple projects match the given project name:"
        matches.each do |path|
          match = path.sub!("#{codebase_dir}/", '')
          STDERR.puts " - #{match}"
        end
        STDERR.puts "\nPlease use a full qualified project name."
        exit 1
      end

      STDERR.puts "No projects match '#{project}'"
      exit 1
    end
  end
end
