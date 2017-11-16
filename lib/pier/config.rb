module Pier
  class Config
    def initialize(options = {})
      @config = {}

      if options.key?(:file) && File.exist?(options[:file])
        load_file!(options[:file])
      end
    end

    def get(key)
      current = @config
      parse_key(key).each do |key_part|
        return nil unless current.key?(key_part)

        current = current[key_part]
      end

      current
    end

    def has?(key)
      current = @config
      parse_key(key).each do |key_part|
        return false unless current.key?(key_part)

        current = current[key_part]
      end
    end

    def set(key, value)
      prev = nil
      current = @config

      keys = parse_key(key)
      keys.each do |key_part|
        current[key_part] = {} unless current.key?(key_part)

        prev = current
        current = current[key_part]
      end

      prev[keys.last] = value if prev
    end

    def load_file!(yaml_file)
      @config = YAML.load_file(yaml_file) if File.exist?(yaml_file)

      @config = {} unless @config.is_a?(Hash)
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
