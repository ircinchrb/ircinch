# frozen_string_literal: true

require_relative "../configuration"

module Cinch
  class Configuration
    # @since 2.0.0
    class Timeouts < Configuration
      KNOWN_OPTIONS = [:read, :connect]

      def self.default_config
        {read: 240, connect: 10}
      end
    end
  end
end
