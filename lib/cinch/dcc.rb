# frozen_string_literal: true

require_relative "dcc/incoming"
require_relative "dcc/outgoing"

module Cinch
  # Cinch supports the following DCC commands:
  #
  # - SEND (both {DCC::Incoming::Send incoming} and
  #   {DCC::Outgoing::Send outgoing})
  # @since 2.0.0
  module DCC
  end
end
