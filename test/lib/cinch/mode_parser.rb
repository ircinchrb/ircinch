require_relative "../../test_helper"
require "cinch/mode_parser"

class ModeParserTest < TestCase
  test "should parse simple modes without params" do
    changes, error = Cinch::ModeParser.parse_modes("+ims", [])
    assert_nil error
    assert_equal [[:add, "i", nil], [:add, "m", nil], [:add, "s", nil]], changes
  end

  test "should parse mode direction switches" do
    changes, error = Cinch::ModeParser.parse_modes("+i-m", [])
    assert_nil error
    assert_equal [[:add, "i", nil], [:remove, "m", nil]], changes
  end

  test "should handle parameters for adding modes" do
    param_modes = { add: ["o", "v"], remove: ["o", "v"] }
    changes, error = Cinch::ModeParser.parse_modes("+o", ["user1"], param_modes)
    assert_nil error
    assert_equal [[:add, "o", "user1"]], changes
  end

  test "should handle parameters for removing modes" do
    param_modes = { add: ["o"], remove: ["o"] }
    changes, error = Cinch::ModeParser.parse_modes("-o", ["user1"], param_modes)
    assert_nil error
    assert_equal [[:remove, "o", "user1"]], changes
  end

  test "should handle mixed modes with and without parameters" do
    param_modes = { add: ["k"], remove: [] }
    changes, error = Cinch::ModeParser.parse_modes("+ik-s", ["key"], param_modes)
    assert_nil error
    assert_equal [
      [:add, "i", nil],
      [:add, "k", "key"],
      [:remove, "s", nil]
    ], changes
  end

  test "should return error for empty string" do
    _, error = Cinch::ModeParser.parse_modes("", [])
    assert_equal Cinch::ModeParser::ERR_EMPTY_STRING, error
  end

  test "should return error for malformed string (start without + or -)" do
    _, error = Cinch::ModeParser.parse_modes("m", [])
    assert_instance_of Cinch::ModeParser::MalformedError, error
    assert_equal "m", error.modes
  end

  test "should return error for empty sequence (+ followed by -)" do
    _, error = Cinch::ModeParser.parse_modes("+-o", [])
    assert_instance_of Cinch::ModeParser::EmptySequenceError, error
  end

  test "should return error for trailing +" do
    _, error = Cinch::ModeParser.parse_modes("+o+", ["param"], {add:['o']})
    assert_instance_of Cinch::ModeParser::EmptySequenceError, error
  end

  test "should return error for not enough parameters" do
    param_modes = { add: ["k"] }
    _, error = Cinch::ModeParser.parse_modes("+k", [], param_modes)
    assert_instance_of Cinch::ModeParser::NotEnoughParametersError, error
    assert_equal "k", error.op
  end

  test "should return error for too many parameters" do
    _, error = Cinch::ModeParser.parse_modes("+i", ["extra"], {})
    assert_instance_of Cinch::ModeParser::TooManyParametersError, error
    assert_equal "+i", error.modes
    assert_equal ["extra"], error.params
  end
end
