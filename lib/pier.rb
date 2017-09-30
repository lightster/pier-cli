require "pier/config"
require "pier/moor"
require "pier/pier"
require "pier/version"

module Pier
  def runShellProc(command)
    begin
      IO.popen(command, :err=>[:child, :out]) do |io|
        while (output = io.getc) do
          print output
          $stdout.flush
        end
      end
    rescue Interrupt => e
    end

    $?
  end

  def runShellProcOrDie(command)
    result = runShellProc command

    if result.exitstatus != 0 && !result.exitstatus.nil? then
      exit result.exitstatus
    end
  end
end
