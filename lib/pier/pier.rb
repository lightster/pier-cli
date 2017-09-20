require 'shellwords'

module Pier
  class Pier
    def initialize(argv)
      @argv = Array.new(argv)
    end

    def run()
      args = Array.new(@argv)
      command = args.shift

      if command == "moor" then
        install(args[0] || "")
        exit 0
      end

      if command == "help" || command.to_s.empty? then
        projects = getAvailableProjects({shortened: true})
        puts <<HELP
Usage:
  pier COMMAND
  pier PROJECT

Available commands:
  moor       Install a project
  help       Output this help documentation

Available projects:
  #{projects.join("\n  ")}
HELP
        exit 0
      end

      runProjectCommand(command, args)
    end

    def install(repo)
      abort "A repo name must be provided" if repo.to_s.empty?

      namespaced_repo = repo.sub('/', '.')

      codebase_dir = "/codebase"
      repo_dir = "#{codebase_dir}/#{namespaced_repo}"

      if !Dir.exist?(repo_dir) then
        git_output = %x(
          cd "#{codebase_dir}" \
            && git clone git@github.com:#{repo}.git "#{repo_dir}" 2>&1
        )

        if $?.exitstatus != 0 then
          STDERR.puts "Error while cloning #{repo}:\n#{git_output}"
        end
      end

      if File.exist?("#{repo_dir}/configure") then
        configure_output = %x(
          cd "#{repo_dir}" \
            && ./configure docker
        )

        if $?.exitstatus != 0 then
          STDERR.puts "Error while running \`./configure docker\`:\n#{configure_output}"
        end
      end

      if File.exist?("#{repo_dir}/Makefile") then
        make_output = %x(
          cd '#{repo_dir}' \
            && make install
        )

        if $?.exitstatus != 0 then
          STDERR.puts "Error while running \`make install\`:\n#{make_output}"
          exit 1
        end
      end
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
