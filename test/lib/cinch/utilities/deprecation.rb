require_relative "../../../test_helper"
require "cinch/utilities/deprecation"

class DeprecationTest < TestCase
  test "print_deprecation warns to stderr" do
    # Capture stderr
    err_stream = StringIO.new
    original_stderr = $stderr
    $stderr = err_stream
    
    begin
      Cinch::Utilities::Deprecation.print_deprecation("2.0.0", "OldMethod", "NewMethod")
    ensure
      $stderr = original_stderr
    end
    
    output = err_stream.string
    assert_match "Deprecation warning: Beginning with version 2.0.0, OldMethod should not be used anymore.", output
    assert_match "Use NewMethod instead.", output
  end

  test "print_deprecation without substitute" do
    err_stream = StringIO.new
    original_stderr = $stderr
    $stderr = err_stream
    
    begin
      Cinch::Utilities::Deprecation.print_deprecation("2.0.0", "OldMethod")
    ensure
      $stderr = original_stderr
    end
    
    output = err_stream.string
    assert_match "should not be used anymore.", output
    refute_match "instead", output
  end
end
