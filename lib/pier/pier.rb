require 'shellwords'

module Pier
  class Pier
    def initialize(argv)
      @argv = Array.new(argv)
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

        exec("
          cd '#{project_dir}' \
            && make #{full_command} 1>&2
        ")
      end
    end

    def getAvailableProjects(options = {})
      codebase_dir = "/codebase"

      files = Dir.entries(codebase_dir).select do |file|
        if file == '.' || file == '..' then
          false
        else
          File.directory? File.join(codebase_dir, file)
        end
      end

      return files if !options[:shortened]

      project_counts = files.each_with_object(Hash.new(0)) do |fq_project, counts|
        project = fq_project.rpartition('.')[2]

        counts[project] += 1
      end

      files.map do |fq_project|
        project = fq_project.rpartition('.')[2]
        if project_counts[project] == 1 then
          project
        else
          fq_project
        end
      end.sort
    end

  private

    def getProjectDir(project)
      codebase_dir = "/codebase"

      repo_dir = "#{codebase_dir}/#{project}"
      if Dir.exists?(repo_dir) then
        return repo_dir
      end

      repo_pattern = "#{codebase_dir}/*.#{project}"
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
