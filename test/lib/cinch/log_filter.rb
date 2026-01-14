# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/log_filter"

class LogFilterTest < TestCase
  test "defines abstract filter method" do
    f = Cinch::LogFilter.new
    # Interface definition usually returns nil or empty body
    assert_nil f.filter("msg", :debug)
  end
end
