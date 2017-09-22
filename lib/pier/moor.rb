
module Pier
  class Moor
    include ::Pier

    def initialize(argv)
      @argv = Array.new(argv)
      # TODO: make this a command line option
      @clone_dir = "/vagrant-nfs/codebase/"
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

      codebase_dir = getCodebaseDir()
      repo_dir = "#{codebase_dir}/#{namespaced_repo}"

      if !Dir.exist?(repo_dir) then
        git_output = %x(
          git clone git@github.com:#{repo}.git "#{@clone_dir}/#{namespaced_repo}" 2>&1
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
