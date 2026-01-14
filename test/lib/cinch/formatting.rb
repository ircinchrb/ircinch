require_relative "../../test_helper"
require "cinch/formatting"

class FormattingTest < TestCase
  test "format adds attributes" do
    result = Cinch::Formatting.format(:bold, "text")
    assert_equal "\x02text\x0F", result
  end

  test "format adds colors" do
    result = Cinch::Formatting.format(:red, "text")
    assert_equal "\x0304text\x0F", result
  end

  test "format supports foreground and background colors" do
    result = Cinch::Formatting.format(:red, :blue, "text")
    # red is 04, blue is 02
    assert_equal "\x0304,02text\x0F", result
  end

  test "format supports mixed attributes and colors" do
    result = Cinch::Formatting.format(:bold, :red, "text")
    # \x02 + \x0304
    # The implementation joins attributes then colors
    assert_equal "\x02\x0304text\x0F", result
  end

  test "format raises error for more than 2 colors" do
    assert_raises(ArgumentError) do
      Cinch::Formatting.format(:red, :blue, :green, "text")
    end
  end

  test "format handles nested formatting" do
    inner = Cinch::Formatting.format(:bold, "bold")
    outer = Cinch::Formatting.format(:underline, "Start #{inner} End")
    # inner is \x02bold\x0F
    # outer is \x1FStart \x02bold\x0F End\x0F
    # But wait, implementation does: string.delete!(attribute_string)
    # And replaces reset code.
    
    # Outer prepend: \x1F (underline)
    # Inner string: \x02bold\x0F (reset is \x0F)
    
    # string.delete!("\x1F") -> no change (inner doesn't have underline)
    
    # string.gsub!(reset, reset + prepend)
    # \x0F becomes \x0F\x1F
    
    # Result: \x1FStart \x02bold\x0F\x1F End\x0F
    
    # Let's verify exact expectation
    # The 'reset' is 15.chr which is \x0F.
    
    expected = "\x1FStart \x02bold\x0F\x1F End\x0F"
    assert_equal expected, outer
  end
  
  test "nested formatting removes duplicate attributes" do
    # format(:bold, format(:bold, "text"))
    inner = Cinch::Formatting.format(:bold, "text") # \x02text\x0F
    outer = Cinch::Formatting.format(:bold, inner)
    
    # Outer prepend: \x02
    # Inner: \x02text\x0F
    # string.delete!("\x02") -> "text\x0F"
    # string.gsub!(\x0F, \x0F\x02) -> "text\x0F\x02"
    # Result: "\x02" + "text\x0F\x02" + "\x0F"
    # "\x02text\x0F\x02\x0F"
    
    expected = "\x02text\x0F\x02\x0F"
    assert_equal expected, outer
  end

  test "unformat removes formatting" do
    formatted = "\x02\x0304,02colored bold\x0F"
    cleaned = Cinch::Formatting.unformat(formatted)
    assert_equal "colored bold", cleaned
  end

  test "unformat removes complex color codes" do
    # \x03 + one digit
    # \x03 + two digits
    s = "\x035text\x0305text"
    assert_equal "texttext", Cinch::Formatting.unformat(s)
  end
end
