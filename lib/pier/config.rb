module Pier
  module Config
    def get(*keys)
      current = @pier_mixin_config
      keys.each do |key|
        current = current[key]
      end

      current
    end

  protected

    def get_all
      @pier_mixin_config
    end

    def init_config(config)
      @pier_mixin_config = config
    end
  end
end
