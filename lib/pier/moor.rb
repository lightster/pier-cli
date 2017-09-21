
module Pier
  class Moor
    def initialize(argv)
      @argv = Array.new(argv)
    end

    def run()
      args = Array.new(@argv)
      command = args.shift

      if command == "install" then
        install(args[0] || "")
        exit 0
      end

      puts <<HELP
Usage:
  moor COMMAND

Available commands:
  install    Install a project
  help       Output this help documentation
HELP
      exit 0
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
  end
end
