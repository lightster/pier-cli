
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
        runShellProcOrDie %W(
          git clone git@github.com:#{repo}.git #{@clone_dir}/#{namespaced_repo}
        )
      end

      if File.exist?("#{repo_dir}/configure") then
        runShellProcOrDie %Q(cd "#{repo_dir}" && ./configure docker)
      end

      if File.exist?("#{repo_dir}/Makefile") then
        runShellProcOrDie %Q(cd '#{repo_dir}' && make install)
      end
    end
  end
end
