# frozen_string_literal: true

# Extensions to Ruby's String class.
class String
  # Like `String#downcase`, but respecting different IRC casemaps.
  #
  # @param [:rfc1459, :"strict-rfc1459", :ascii] mapping
  # @return [String]
  def irc_downcase(mapping)
    case mapping
    when :rfc1459
      tr("A-Z[]\\\\^", "a-z{}|~")
    when :"strict-rfc1459"
      tr("A-Z[]\\\\", "a-z{}|")
    else
      # when :ascii or unknown/nil
      tr("A-Z", "a-z")
    end
  end

  # Like `String#upcase`, but respecting different IRC casemaps.
  #
  # @param [:rfc1459, :"strict-rfc1459", :ascii] mapping
  # @return [String]
  def irc_upcase(mapping)
    case mapping
    when :ascii
      tr("a-z", "A-Z")
    when :rfc1459
      tr("a-z{}|~", "A-Z[]\\\\^")
    when :"strict-rfc1459"
      tr("a-z{}|", "A-Z[]\\\\")
    end
  end
end
