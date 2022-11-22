# frozen_string_literal: true

require_relative "../configuration"

module Cinch
  class Configuration
    # @since 2.0.0
    class DCC < Configuration
      KNOWN_OPTIONS = [:own_ip]

      def self.default_config
        {
          own_ip: nil
        }
      end
    end
  end
end
