# frozen_string_literal: true

require_relative "../configuration"
require_relative "../sasl"

module Cinch
  class Configuration
    # @since 2.0.0
    class SASL < Configuration
      KNOWN_OPTIONS = [:username, :password, :mechanisms]

      def self.default_config
        {
          username: nil,
          password: nil,
          mechanisms: [Cinch::SASL::DhBlowfish, Cinch::SASL::Plain]
        }
      end
    end
  end
end
