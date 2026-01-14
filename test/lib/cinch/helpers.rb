# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/helpers"
require "cinch/plugin"

class HelpersTest < TestCase
  class TestPlugin
    include Cinch::Plugin

    # Cinch::Plugin includes Helpers automatically
    attr_reader :bot
    def initialize(bot)
      @bot = bot
      @timers = []
      @files = [] # Helpers uses this too? No, verify plugin.rb
    end

    def foo
    end
  end

  class MockBot
    attr_reader :channel_list, :user_list, :loggers, :nick
    def initialize
      @channel_list = MockList.new
      @user_list = MockList.new
      @loggers = MockLoggerList.new
      @nick = "bot"
    end
  end

  class MockList
    def find_ensured(name)
      name
    end
  end

  class MockLoggerList
    attr_reader :logs
    def initialize
      @logs = []
    end

    def exception(e)
      @logs << e
    end

    def log(m, e, l)
      @logs << [m, e, l]
    end

    def debug(m)
      @logs << [:debug, m]
    end

    def error(m)
      @logs << [:error, m]
    end

    def fatal(m)
      @logs << [:fatal, m]
    end

    def info(m)
      @logs << [:info, m]
    end

    def warn(m)
      @logs << [:warn, m]
    end

    def incoming(m)
      @logs << [:incoming, m]
    end

    def outgoing(m)
      @logs << [:outgoing, m]
    end
  end

  def setup
    @bot = MockBot.new
    @plugin = TestPlugin.new(@bot)
  end

  test "Target helper" do
    t = @plugin.Target("user")
    assert_kind_of Cinch::Target, t
    assert_equal "user", t.name
  end

  test "Channel helper" do
    # MokList returns the name string, but normally it returns a Channel object.
    # checking that it delegates to channel_list.find_ensured
    c = @plugin.Channel("#chan")
    assert_equal "#chan", c
  end

  test "User helper" do
    u = @plugin.User("user")
    assert_equal "user", u

    # Special case: bot nick
    u_bot = @plugin.User("bot")
    assert_equal @bot, u_bot
  end

  class MockTimer
    attr_reader :started
    def initialize
      @started = false
    end

    def start
      @started = true
    end
  end

  test "Timer helper" do
    mock_timer = MockTimer.new

    # We need to stub Cinch::Timer.new.
    # Since Cinch::Timer is a class, we stub :new on it.
    with_stub(Cinch::Timer, :new, ->(*args, &block) { mock_timer }) do
      t = @plugin.Timer(1, method: :foo)
      assert_equal mock_timer, t
    end
    assert mock_timer.started
  end

  test "rescue_exception logs exception" do
    e = StandardError.new("oops")
    @plugin.rescue_exception do
      raise e
    end
    assert_equal e, @bot.loggers.logs.last
  end

  test "Format/Color helper" do
    # Format might append reset explicitly if not present?
    # Actually Format(color, string) produces "\x03" + "code" + string + "\x0F"

    assert_equal "\x0304text\x0F", @plugin.Format(:red, "text")

    # deprecation prints to stderr
    _, err = capture_io do
      assert_equal "\x0304text\x0F", @plugin.Color(:red, "text")
    end
    assert_match(/Deprecation/, err)
  end

  test "Sanitize helper" do
    assert_equal "foobar", @plugin.Sanitize("foo\nbar")
    assert_equal "ab", @plugin.Sanitize("a\r\nb")
  end

  test "Unformat helper" do
    assert_equal "text", @plugin.Unformat("\x0304text\x03")
  end

  test "Logging helpers" do
    @plugin.debug("d")
    # log(messages, event, level)
    # messages is array
    last_log = @bot.loggers.logs.last
    # last_log = [messages, event, level]

    messages = last_log[0]
    event = last_log[1]

    assert_equal :debug, event
    assert_match(/\[HelpersTest::TestPlugin\] d/, messages.first)
  end
end
