require_relative "../../../test_helper"
require "cinch/rubyext/float"

class RubyextFloatTest < TestCase
  test "INFINITY is defined" do
    assert defined?(Float::INFINITY)
    assert_equal 1.0/0.0, Float::INFINITY
  end
end
