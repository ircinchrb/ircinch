# frozen_string_literal: true

require_relative "../../../test_helper"
require "cinch/rubyext/string"

class RubyextStringTest < TestCase
  test "irc_downcase handling for rfc1459" do
    assert_equal "abc{}|~", "ABC[]\\^".irc_downcase(:rfc1459)
  end

  test "irc_downcase handling for strict-rfc1459" do
    assert_equal "abc{}|", "ABC[]\\".irc_downcase(:"strict-rfc1459")
  end

  test "irc_downcase handling for ascii" do
    assert_equal "abc[]\\^", "ABC[]\\^".irc_downcase(:ascii)
  end

  test "irc_upcase handling for rfc1459" do
    assert_equal "ABC[]\\^", "abc{}|~".irc_upcase(:rfc1459)
  end

  test "irc_upcase handling for strict-rfc1459" do
    assert_equal "ABC[]\\", "abc{}|".irc_upcase(:"strict-rfc1459")
  end

  test "irc_upcase handling for ascii" do
    assert_equal "ABC{|}~", "abc{|}~".irc_upcase(:ascii)
  end
end
