# frozen_string_literal: true

require_relative "../configuration"

module Cinch
  class Configuration
    # @since 2.0.0
    class Plugins < Configuration
      KNOWN_OPTIONS = [:plugins, :prefix, :suffix, :options]

      def self.default_config
        {
          plugins: [],
          prefix: /^!/,
          suffix: nil,
          options: Hash.new { |h, k| h[k] = {} }
        }
      end

      def load(new_config, from_default = false)
        fresh_new_config = {}
        new_config.each do |option, value|
          case option
          when :plugins
            fresh_new_config[option] = value.map { |v| Cinch::Utilities::Kernel.string_to_const(v) }
          when :options
            fresh_value = self[:options]
            value.each do |k, v|
              k = Cinch::Utilities::Kernel.string_to_const(k)
              v = self[:options][k].merge(v)
              fresh_value[k] = v
            end
            fresh_new_config[option] = fresh_value
          else
            fresh_new_config[option] = value
          end
        end

        super(fresh_new_config, from_default)
      end
    end
  end
end
