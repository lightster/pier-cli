require 'pier/moor'
require 'pier/pier'
require 'pier/version'

module Pier
  def runShellProc(command)
    system(command)
    $?
  end

  def runShellProcOrDie(command)
    result = runShellProc command

    if result.exitstatus != 0 && !result.exitstatus.nil? then
      exit result.exitstatus
    end
  end
end
