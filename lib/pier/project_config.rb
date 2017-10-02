require "pier/config"

module Pier
  class ProjectConfig
    def initialize
      @defaults = Config.new
      @defaults.set('moor.install.configure', './configure docker')
      @defaults.set('moor.install.make', 'make install')
    end

    def get(key)
      @defaults.get(key)
    end
  end
end
