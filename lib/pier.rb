require "pier/moor"
require "pier/pier"
require "pier/version"

module Pier
  def getCodebaseDir
    File.dirname(__FILE__) + "/../../"
  end
end
