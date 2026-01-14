require_relative "../../../test_helper"
require "cinch/rubyext/module"

class RubyextModuleTest < TestCase
  class MockClass
    attr_accessor :attr_calls
    
    def initialize
      @attr_calls = []
    end
    
    # Mock the attr method expected by synced_attr_reader
    def attr(name, writable = false, unsynced = false)
      @attr_calls << [name, writable, unsynced]
      :value
    end
    
    def foo; end
    synced_attr_reader :foo
    

    def bar; end
    synced_attr_accessor :bar
  end

  def setup
    @obj = MockClass.new
  end

  test "synced_attr_reader defines reader calling attr" do
    assert_respond_to @obj, :foo
    assert_equal :value, @obj.foo
    assert_equal [[:foo, false, false]], @obj.attr_calls
  end

  test "synced_attr_reader defines unsynced reader" do
    assert_respond_to @obj, :foo_unsynced
    @obj.foo_unsynced
    # last call calls attr with unsynced=true
    assert_equal [:foo, false, true], @obj.attr_calls.last
  end
  
  test "synced_attr_accessor defines reader and writer" do
    assert_respond_to @obj, :bar
    assert_respond_to @obj, :bar=
    
    @obj.bar
    assert_equal [:bar, false, false], @obj.attr_calls.last
    
    # writer uses standard attr_accessor, so it sets instance var
    @obj.bar = 123
    assert_equal 123, @obj.instance_variable_get(:@bar)
  end
end
