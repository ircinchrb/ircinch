require_relative "../../test_helper"
require "cinch/handler"

class HandlerTest < TestCase
  class MockLoggerList
    def debug(msg); end
    def exception(e); end
  end



  class MockBot
    attr_reader :loggers, :handlers, :callback
    def initialize
      @loggers = MockLoggerList.new
      @handlers = MockHandlerList.new
      @callback = Object.new
    end
  end

  class MockHandlerList
    def unregister(handler); end
  end

  class MockPattern
  end

  def setup
    @bot = MockBot.new
    @pattern = MockPattern.new
  end

  test "initialize sets attributes" do
    handler = Cinch::Handler.new(@bot, :message, @pattern, group: :test_group, strip_colors: true)
    
    assert_equal :message, handler.event
    assert_equal @pattern, handler.pattern
    assert_equal :test_group, handler.group
    assert handler.strip_colors
  end

  test "unregister calls bot handlers unregister" do
    handler = Cinch::Handler.new(@bot, :message, @pattern)
    
    called = false
    mock_handlers = Object.new
    mock_handlers.define_singleton_method(:unregister) do |h|
      called = true if h == handler
    end
    
    @bot.instance_variable_set(:@handlers, mock_handlers) # Hack to inject mock
    
    handler.unregister
    assert called
  end

  test "call executes block in thread" do
    executed = false
    handler = Cinch::Handler.new(@bot, :message, @pattern) do
      executed = true
    end
    
    t = handler.call(nil, [], [])
    t.join
    assert executed
  end

  test "call passes arguments to block" do
    args_received = nil
    handler = Cinch::Handler.new(@bot, :message, @pattern) do |*args|
      args_received = args
    end
    
    t = handler.call(:msg, [:capture], [:arg])
    t.join
    
    # Block receives: message, *args, *bargs (captures + arguments)
    # call(message, captures, arguments)
    # bargs = captures + arguments = [:capture, :arg]
    # block.call(message, *args (from options), *bargs)
    
    # Expected: [:msg, :capture, :arg]
    assert_equal [:msg, :capture, :arg], args_received
  end
  
  test "stop kills threads" do
    handler = Cinch::Handler.new(@bot, :message, @pattern) do
      sleep 10
    end
    
    # Override timeout for testing
    def handler.stop_timeout; 0.1; end
    
    t = handler.call(nil, [], [])
    # Wait for thread to start and be added to thread_group
    sleep 0.2
    assert t.alive?
    assert_includes handler.thread_group.list, t
    
    handler.stop
    
    # Wait for thread to die (timeout + buffer)
    # The killer thread waits 0.1s then kills.
    max_retries = 20
    while t.alive? && max_retries > 0
      sleep 0.1
      max_retries -= 1
    end
    
    refute t.alive?
  end
end
