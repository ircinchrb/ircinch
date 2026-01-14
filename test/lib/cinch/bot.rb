# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/bot"

class BotTest < TestCase
  class MockIRC
    attr_accessor :network
    attr_reader :sent, :isupport
    def initialize(bot)
      @network = OpenStruct.new(unknown_network: true)
      @sent = []
      @isupport = {"NICKLEN" => 9}
    end

    def setup
    end

    def send(msg)
      @sent << msg
    end
  end

  class MockLoggerList
    def debug(msg)
    end

    def info(msg)
    end

    def error(msg)
    end
  end

  class MockChannel
    attr_reader :name
    def initialize(name, bot)
      @name = name
    end

    def join(key = nil)
    end

    def part(reason = nil)
    end
  end

  def setup
    @bot = Cinch::Bot.new
    @bot.loggers.clear # silence logs
    # Stub internal @irc with better mock
    @mock_irc = MockIRC.new(@bot)
    @bot.instance_variable_set(:@irc, @mock_irc)
    # Set a default nick for valid command generation (e.g. MODE bot +x)
    @bot.set_nick("bot")
  end

  test "initialize sets up components" do
    assert_instance_of Cinch::Configuration::Bot, @bot.config
    assert_instance_of Cinch::LoggerList, @bot.loggers
    assert_instance_of Cinch::UserList, @bot.user_list
    assert_instance_of Cinch::ChannelList, @bot.channel_list
    assert_instance_of Cinch::PluginList, @bot.plugins
    # assert_instance_of Cinch::IRC, @bot.irc # Mocked
  end

  test "initialize with block parses config" do
    bot = Cinch::Bot.new do
      configure do |c|
        c.nick = "testbot"
        c.server = "localhost"
      end
    end

    assert_equal "testbot", bot.config.nick
    assert_equal "localhost", bot.config.server
  end

  test "quit sets quitting flag" do
    refute @bot.quitting
    @bot.quit("reason")
    assert @bot.quitting
    assert_includes @mock_irc.sent, "QUIT :reason"
  end

  test "bot is a user" do
    assert_kind_of Cinch::User, @bot
  end

  test "on registers handler" do
    @bot.on(:message, /foo/) {}
    assert_includes @bot.handlers.map(&:event), :message
  end

  test "nick= sends NICK" do
    @bot.nick = "newnick"
    assert_equal "newnick", @bot.config.nick
    assert_includes @mock_irc.sent, "NICK newnick"
  end

  test "oper sends OPER" do
    @bot.config.nick = "bot"
    @bot.oper("pass")
    assert_includes @mock_irc.sent, "OPER bot pass"

    @mock_irc.sent.clear
    @bot.oper("pass", "user")
    assert_includes @mock_irc.sent, "OPER user pass"
  end

  test "set_mode/unset_mode sends MODE" do
    @bot.config.nick = "bot"

    @bot.set_mode("x")
    assert_includes @mock_irc.sent, "MODE bot +x"
    assert_includes @bot.modes, "x"

    @mock_irc.sent.clear
    @bot.unset_mode("x")
    assert_includes @mock_irc.sent, "MODE bot -x"
    refute_includes @bot.modes, "x"
  end

  test "modes= updates modes" do
    @bot.config.nick = "bot"
    @bot.set_mode("a")
    @mock_irc.sent.clear

    @bot.modes = ["b"]
    # Should unset a and set b
    assert_includes @mock_irc.sent, "MODE bot -a"
    assert_includes @mock_irc.sent, "MODE bot +b"
    assert_equal ["b"], @bot.modes
  end

  test "generate_next_nick! rotation" do
    @bot.config.nicks = ["bot", "bot_"]
    @bot.config.nick = "bot"

    @bot.generate_next_nick!("bot")
    assert_equal "bot_", @bot.config.nick

    @bot.generate_next_nick!("bot_")
    assert_equal "bot__", @bot.config.nick
  end

  test "synchronize yields" do
    yielded = false
    @bot.synchronize(:test) do
      yielded = true
    end
    assert yielded
  end

  test "join delegates to Channel" do
    channel = MockChannel.new("#foo", @bot)

    # Manually stub Channel helper on bot instance
    @bot.define_singleton_method(:Channel) { |name| channel }

    channel.define_singleton_method(:join) { |key = nil|
      @joined = true
      @key = key
    }

    @bot.join("#foo", "key")
    assert channel.instance_variable_get(:@joined)
    assert_equal "key", channel.instance_variable_get(:@key)
  end

  test "part delegates to Channel" do
    channel = MockChannel.new("#foo", @bot)

    @bot.define_singleton_method(:Channel) { |name| channel }

    channel.define_singleton_method(:part) { |reason = nil|
      @parted = true
      @reason = reason
    }

    @bot.part("#foo", "bye")
    assert channel.instance_variable_get(:@parted)
    assert_equal "bye", channel.instance_variable_get(:@reason)
  end
end
