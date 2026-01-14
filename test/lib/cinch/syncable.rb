require_relative "../../test_helper"
require "cinch/syncable"
require "cinch/exceptions"

class SyncableTest < TestCase
  class MockBot
    attr_reader :loggers
    def initialize
      @loggers = MockLoggerList.new
    end
  end
  class MockLoggerList
    def warn(msg); end
  end

  class TestObject
    include Cinch::Syncable
    attr_accessor :bot
    
    def initialize
      @bot = MockBot.new
      @synced_attributes = []
      @data = {}
    end
    
    def inspect; "TestObject"; end
  end

  def setup
    @obj = TestObject.new
  end

  test "sync marks attribute as synced" do
    @obj.sync(:foo, "bar")
    assert @obj.attribute_synced?(:foo)
    assert_equal "bar", @obj.instance_variable_get(:@foo)
  end
  
  test "sync with data stores in hash" do
    @obj.sync(:foo, "bar", true)
    assert @obj.attribute_synced?(:foo)
    assert_equal "bar", @obj.instance_variable_get(:@data)[:foo]
  end

  test "wait_until_synced returns if synced" do
    @obj.sync(:foo, "bar")
    # Should not block
    Timeout.timeout(1) do
      @obj.wait_until_synced(:foo)
    end
  end
  
  test "unsync removes attribute" do
    @obj.sync(:foo, "bar")
    @obj.unsync(:foo)
    refute @obj.attribute_synced?(:foo)
  end
  
  test "unsync_all clears all" do
    @obj.sync(:foo, "bar")
    @obj.sync(:baz, "qux")
    @obj.unsync_all
    refute @obj.attribute_synced?(:foo)
    refute @obj.attribute_synced?(:baz)
  end
  
  test "wait_until_synced loops and raises" do
    # We need to stub sleep to avoid waiting
    # We expect it to try 300 times (30s / 0.1s)
    
    sleep_calls = 0
    with_stub(Kernel, :sleep, ->(t) { sleep_calls += 1 }) do
       # Also stub instance's sleep if it calls Kernel.sleep or whatever
       # wait_until_synced calls `sleep 0.1` which is private instance method on Object/Kernel
       # But since test runs in instances, we might need to stub on @obj
       
       # Actually simpler: stub attribute_synced? to eventually return true?
       # Or to verify timeout, return false.
       
       def @obj.sleep(t); end # stub instance sleep
       
       assert_raises(Cinch::Exceptions::SyncedAttributeNotAvailable) do
         @obj.wait_until_synced(:missing)
       end
       
       # It waits 30s, checking every 0.1s => ~300 checks
       # Wait logic: waited / 10 >= 30 => waited >= 300. 
       # So unblocking is correct.
    end
  end

  test "attr retrieves synced value" do
    @obj.sync(:foo, "val")
    assert_equal "val", @obj.attr(:foo)
  end

  test "attr retrieves data value" do
    @obj.sync(:foo, "val", true)
    assert_equal "val", @obj.attr(:foo, true)
  end

  test "attr with unsync: true skips waiting" do
    # :missing is not synced, so regular attr would block/raise
    # with unsync: true it should just return nil (instance var default)
    assert_nil @obj.attr(:missing, false, true)
  end

  test "mark_as_synced adds to synced attributes" do
    @obj.mark_as_synced(:foo)
    assert @obj.attribute_synced?(:foo)
  end
  
  test "wait_until_synced warns while waiting" do
    def @obj.sleep(t); end
    
    warnings = []
    @obj.bot.loggers.define_singleton_method(:warn) { |msg| warnings << msg }
    
    assert_raises(Cinch::Exceptions::SyncedAttributeNotAvailable) do
      @obj.wait_until_synced(:missing)
    end
    
    refute_empty warnings
    assert_match "still waiting", warnings.join
  end
end
