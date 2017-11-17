require 'English'
require 'pier/moor'
require 'pier/pier'
require 'pier/version'

module Pier
  def runShellProc(command)
    begin
      if command.respond_to?('each')
        command = command.map(&:shellescape).join(' ')
      end

      system(command)
    rescue Interrupt
    end

    $CHILD_STATUS
  end

  def runShellProcOrDie(command)
    result = runShellProc command

    if !result.nil? && result.exitstatus != 0 && !result.exitstatus.nil?
      exit result.exitstatus
    end
  end
end
