module Pier
  class ProjectConfig
    def initialize
      @config = {
        'moor' => {
          'install' => {
            'configure' => './configure docker',
            'make' => 'make install',
          },
        },
      }
    end

    def get(*keys)
      current = @config
      keys.each do |key|
        current = current[key]
      end

      current
    end
  end
end
