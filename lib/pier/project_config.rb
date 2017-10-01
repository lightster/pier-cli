require "pier/config"

module Pier
  class ProjectConfig
    include Config

    def initialize
      init_config({
        'moor' => {
          'install' => {
            'configure' => './configure docker',
            'make' => 'make install',
          },
        },
      })
    end
  end
end
