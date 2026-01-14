# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/user"

class UserTest < TestCase
  class MockIRC
    attr_reader :sends, :network, :isupport, :socket
    def initialize
      @sends = []
      @network = OpenStruct.new(whois_only_one_argument?: false)
      @isupport = {"MONITOR" => 0}
      @socket = OpenStruct.new(addr: ["AF_INET", 1234, "127.0.0.1", "127.0.0.1"])
    end

    def send(msg)
      @sends << msg
    end
  end

  class MockBot
    attr_reader :irc, :user_list, :config, :handlers, :loggers
    def initialize
      @irc = MockIRC.new
      @user_list = MockUserList.new
      @config = OpenStruct.new(dcc: OpenStruct.new)
      @handlers = MockHandlers.new
      @loggers = MockLoggers.new
    end

    def nick
      "bot"
    end

    def on(*args)
    end
  end

  class MockUserList
    def find_ensured(name)
    end

    def update_nick(user)
    end
  end

  class MockHandlers
    def dispatch(*args)
    end

    def register(handler)
    end
  end

  class MockLoggers
    def debug(m)
    end

    def info(m)
    end

    def warn(m)
    end
  end

  def setup
    @bot = MockBot.new
    @user = Cinch::User.new("foo", @bot)
  end

  test "initialization" do
    assert_equal "foo", @user.nick
    @user.sync(:unknown?, false, true)
    refute @user.unknown?
  end

  test "mask generation" do
    @user.sync(:user, "u", true)
    @user.sync(:host, "h", true)

    mask = @user.mask
    assert_equal "foo!u@h", mask.to_s
  end

  test "custom mask generation" do
    @user.sync(:user, "u", true)
    @user.sync(:host, "h", true)
    mask = @user.mask("%n!%u@%h")
    assert_equal "foo!u@h", mask.to_s
  end

  test "update_nick" do
    @user.update_nick("bar")
    assert_equal "bar", @user.nick
    assert_equal "foo", @user.last_nick
  end

  test "match against strings/masks" do
    @user.sync(:user, "u", true)
    @user.sync(:host, "h", true)

    assert @user.match("foo!u@h")
    assert @user.match("foo!*@*")
  end

  test "authed?" do
    @user.sync(:authname, nil, true)
    refute @user.authed?
    @user.sync(:authname, "account", true)
    assert @user.authed?
  end

  test "refresh sends WHOIS" do
    @user.refresh
    assert_equal "WHOIS foo foo", @bot.irc.sends.last
  end

  class MockTimer
    attr_reader :started, :stopped
    def initialize
      @started = false
      @stopped = false
    end

    def start
      @started = true
    end

    def stop
      @stopped = true
    end
  end

  test "monitor using WHOIS loop if MONITOR not supported" do
    mock_timer = MockTimer.new

    with_stub(Cinch, :const_defined?, ->(c) { c == :Timer || super(c) }) do
      # We need to stub Cinch::Timer constant? No, it might not exist.
      # If Cinch::Timer is not loaded, we can define a stub class or require it?
      # Better: define a dummy class in test if missing, or use stub.
      # But User code calls Cinch::Timer.new.

      # Let's define Cinch::Timer if missing, or stub it.
      # But redefining constant is warned.
      # Safest: Use with_stub on Cinch module to return MockTimer class? No.
      # Stub Cinch::Timer.new if Cinch::Timer exists.

      # Let's require the real timer and then stub new.
      require "cinch/timer"

      with_stub(Cinch::Timer, :new, ->(*args, &block) { mock_timer }) do
        @user.monitor
        assert_includes @bot.irc.sends, "WHOIS foo foo"
        assert mock_timer.started

        @user.unmonitor
        assert mock_timer.stopped
      end
    end
  end

  test "to_s returns nick" do
    assert_equal "foo", @user.to_s
  end

  test "inspect" do
    assert_equal "#<User nick=\"foo\">", @user.inspect
  end
  test "end_of_whois syncs attributes" do
    data = {user: "u", host: "h", realname: "r", authname: "a", idle: 123, signed_on_at: Time.now}
    @user.end_of_whois(data)

    assert_equal "u", @user.user
    assert_equal "h", @user.host
    assert_equal "r", @user.realname
    assert_equal "a", @user.authname
    assert_equal 123, @user.idle
    assert @user.online?
    refute @user.unknown?
  end

  test "end_of_whois handles unknown user" do
    @user.end_of_whois({unknown?: true})
    assert @user.unknown?
    refute @user.online?
  end

  test "online= dispatches events" do
    @user.monitor # needs to be monitored to dispatch events

    # We need to spy on bot handlers dispatch
    handlers = @bot.handlers
    def handlers.dispatch(event, *args)
      @dispatched ||= []
      @dispatched << event
    end

    def handlers.dispatched
      @dispatched
    end

    @user.online = true
    assert_includes @bot.handlers.dispatched, :online

    @user.online = false
    assert_includes @bot.handlers.dispatched, :offline
  end
end
