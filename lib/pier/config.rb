module Pier
  module Config
    def get(key)
      current = @pier_mixin_config
      parse_key(key).each do |key_part|
        return nil if !current.key?(key_part)

        current = current[key_part]
      end

      current
    end

    def has?(key)
      current = @pier_mixin_config
      parse_key(key).each do |key_part|
        return false if !current.key?(key_part)

        current = current[key_part]
      end
    end

    def set(key, value)
      prev = nil
      current = @pier_mixin_config

      keys = parse_key(key)
      keys.each do |key_part|
        if !current.key?(key_part) then
          current[key_part] = {}
        end

        prev = current
        current = current[key_part]
      end

      if prev then
        prev[keys.last] = value
      end
    end

  protected

    def get_all
      @pier_mixin_config
    end

    def init_config(config)
      @pier_mixin_config = config
    end

  private

    def parse_key(key)
      parsed_keys = []
      key.split(/\.+/).each do |key_part|
        parsed_keys.push(key_part)
      end

      parsed_keys
    end

  end
end
