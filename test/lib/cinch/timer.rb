require_relative "../../test_helper"
require "cinch/timer"

class TimerTest < TestCase
  class MockLoggerList
    def debug(msg); end
  end

  class MockBot
    attr_reader :loggers
    def initialize
      @loggers = MockLoggerList.new
    end
    def on(event, pattern, object, &block); end
  end

  def setup
    @bot = MockBot.new
  end

  test "initialize sets attributes" do
    t = Cinch::Timer.new(@bot, interval: 10, shots: 5)
    assert_equal 10.0, t.interval
    assert_equal 5, t.shots
    assert t.threaded?
  end

  test "start adds to thread group" do
    t = Cinch::Timer.new(@bot, interval: 0.1, shots: 1)
    t.start
    assert t.started?
    assert_equal 1, t.thread_group.list.size
    t.stop
  end

  test "stop kills threads" do
    t = Cinch::Timer.new(@bot, interval: 10, shots: 1)
    t.start
    t.stop
    
    # Wait for threads to die
    max_retries = 10
    while t.thread_group.list.any?(&:alive?) && max_retries > 0
      sleep 0.05
      max_retries -= 1
    end
    
    assert t.stopped?
    assert_empty t.thread_group.list.select(&:alive?)
  end

  test "timer executes block" do
    executed = false
    t = Cinch::Timer.new(@bot, interval: 0.1, shots: 1) do
      executed = true
    end
    t.start
    sleep 0.2
    assert executed
  end
  
  test "timer respects shot count" do
    count = 0
    t = Cinch::Timer.new(@bot, interval: 0.05, shots: 3) do
      count += 1
    end
    t.start
    sleep 0.3
    assert_equal 3, count
  end
  
  test "timer can be unthreaded" do
    t = Cinch::Timer.new(@bot, interval: 1, threaded: false)
    refute t.threaded?
  end

  test "registers auto start/stop listeners" do
    hooks = []
    @bot.define_singleton_method(:on) do |event, *, &block|
      hooks << event
    end
    
    Cinch::Timer.new(@bot, interval: 1)
    
    assert_includes hooks, :connect
    assert_includes hooks, :disconnect
  end

  test "to_s returns string representation" do
    t = Cinch::Timer.new(@bot, interval: 1, shots: 5)
    assert_match(/0\/5 shots/, t.to_s)
    assert_match(/1s interval/, t.to_s)
  end
  
  test "timer handles exceptions safely" do
    # Helpers#rescue_exception logs exceptions.
    # We can spy on the logger.
    loggers = @bot.loggers
    def loggers.exception(e); @last_exception = e; end
    def loggers.last_exception; @last_exception; end
    
    t = Cinch::Timer.new(@bot, interval: 0.1, shots: 1) do
      raise "oops"
    end
    t.start
    sleep 0.2
    
    assert_equal "oops", @bot.loggers.last_exception.message
  end
end
