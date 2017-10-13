module Pier
  class Config
    def initialize(options = {})
      @config = {}

      if options.key?(:file) && File.exists?(options[:file]) then
        load_file!(options[:file])
      end
    end

    def get(key)
      current = @config
      parse_key(key).each do |key_part|
        return nil if !current.key?(key_part)

        current = current[key_part]
      end

      current
    end

    def has?(key)
      current = @config
      parse_key(key).each do |key_part|
        return false if !current.key?(key_part)

        current = current[key_part]
      end
    end

    def set(key, value)
      prev = nil
      current = @config

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

    def load_file!(yaml_file)
      if File.exists?(yaml_file)
        @config = YAML.load_file(yaml_file)
      end

      if !@config.is_a?(Hash) then
        @config = {}
      end
    end

    def save_file(yaml_file)
      File.write(yaml_file, @config.to_yaml)
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
