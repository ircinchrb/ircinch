# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/handler_list"

class HandlerListTest < TestCase
  class MockParams
    def last
      ""
    end
  end

  class MockMessage
    def match(regexp, event, strip_colors)
      # Return a match data object or nil
      "test message".match(regexp)
    end

    def params
      MockParams.new
    end
  end

  class MockPattern
    def to_r(msg = nil)
      /test/
    end

    def inspect
      "/test/"
    end
  end

  class MockBot
    attr_reader :loggers
    def initialize
      @loggers = MockLoggerList.new
    end
  end

  class MockLoggerList
    def debug(msg)
    end
  end

  class MockHandler
    attr_reader :event, :pattern, :bot, :group, :strip_colors, :block
    def initialize(bot, event, pattern, group = nil, &block)
      @bot = bot
      @event = event
      @pattern = pattern
      @group = group
      @strip_colors = false
      @block = block || proc {}
    end

    def call(msg, captures, args)
      Thread.new { @block.call(msg, captures, args) }
    end

    def stop
    end
  end

  def setup
    @list = Cinch::HandlerList.new
    @bot = MockBot.new
  end

  test "register adds handler" do
    handler = MockHandler.new(@bot, :message, MockPattern.new)
    @list.register(handler)
    assert_includes @list.map(&:object_id), handler.object_id
  end

  test "unregister removes handler" do
    handler = MockHandler.new(@bot, :message, MockPattern.new)
    @list.register(handler)
    @list.unregister(handler)
    refute_includes @list.map(&:object_id), handler.object_id
  end

  test "find returns handlers for event" do
    handler = MockHandler.new(@bot, :message, MockPattern.new)
    @list.register(handler)
    assert_includes @list.find(:message), handler
    assert_empty @list.find(:other_event)
  end

  test "find with message filters by pattern" do
    handler1 = MockHandler.new(@bot, :message, MockPattern.new) # matches "test"
    handler2 = MockHandler.new(@bot, :message, Object.new) # Mock pattern fail
    def (handler2.pattern).to_r(msg)
      /nomatch/
    end

    def (handler2.pattern).inspect
      "/nomatch/"
    end

    @list.register(handler1)
    @list.register(handler2)

    msg = MockMessage.new
    result = @list.find(:message, msg)
    assert_includes result, handler1
    refute_includes result, handler2
  end

  test "find handles groups" do
    # Handlers in same group should only return the first one
    h1 = MockHandler.new(@bot, :message, MockPattern.new, :group1)
    h2 = MockHandler.new(@bot, :message, MockPattern.new, :group1)
    @list.register(h1)
    @list.register(h2)

    msg = MockMessage.new
    result = @list.find(:message, msg)
    assert_equal 1, result.size
    assert_includes result, h1
  end

  test "dispatch calls handlers" do
    called = false
    handler = MockHandler.new(@bot, :message, MockPattern.new) do
      called = true
    end
    @list.register(handler)

    threads = @list.dispatch(:message, MockMessage.new)
    threads.each(&:join)

    assert called
  end
end
