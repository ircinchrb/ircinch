# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/message"

class MessageTest < TestCase
  class MockParams
    def last
      ""
    end
  end

  class MockNetwork
    def ngametv?
      false
    end
  end

  class MockISupport
    def [](key)
      case key
      when "CHANTYPES" then ["#", "&"]
      when "STATUSMSG" then ["@", "+"]
      when "PREFIX" then {"o" => "@", "v" => "+"}
      end
    end
  end

  class MockIRC
    def network
      MockNetwork.new
    end

    def isupport
      MockISupport.new
    end
  end

  class MockUserList
    def find_ensured(user, nick, host)
      # return pseudo user object or string?
      # Message expects object it seems
      "User(#{nick}!#{user}@#{host})"
    end
  end

  class MockChannelList
    def find_ensured(name)
      "Channel(#{name})"
    end
  end

  class MockBot
    attr_reader :irc, :user_list, :channel_list
    def initialize
      @irc = MockIRC.new
      @user_list = MockUserList.new
      @channel_list = MockChannelList.new
    end
  end

  def setup
    @bot = MockBot.new
  end

  test "parses regular PRIVMSG to channel" do
    raw = ":nick!user@host PRIVMSG #channel :hello world"
    msg = Cinch::Message.new(raw, @bot)

    assert_equal "nick", msg.prefix[/^(\S+)!/, 1]
    assert_equal "PRIVMSG", msg.command
    assert_equal ["#channel", "hello world"], msg.params
    assert_equal "hello world", msg.message
    assert msg.channel?
    assert_equal "Channel(#channel)", msg.channel
    assert_equal "User(nick!user@host)", msg.user
  end

  test "parses PRIVMSG to user" do
    raw = ":nick!user@host PRIVMSG target :private message"
    msg = Cinch::Message.new(raw, @bot)

    assert_equal "target", msg.params.first
    refute msg.channel?
    assert_nil msg.channel
  end

  test "parses numeric reply" do
    raw = ":server 001 nick :Welcome to IRC"
    msg = Cinch::Message.new(raw, @bot)

    assert msg.numeric_reply?
    refute msg.error?
    assert_equal "001", msg.command
  end

  test "parses error reply" do
    raw = ":server 404 nick #channel :Cannot join channel"
    msg = Cinch::Message.new(raw, @bot)

    assert msg.error?
    assert_equal 404, msg.error
  end

  test "parses CTCP ACTION" do
    raw = ":nick!user@host PRIVMSG #channel :\001ACTION dances\001"
    msg = Cinch::Message.new(raw, @bot)

    assert msg.ctcp?
    assert msg.action?
    assert_equal "dances", msg.action_message
    assert_equal "ACTION", msg.ctcp_command
  end

  test "parses standard CTCP" do
    raw = ":nick!user@host PRIVMSG #channel :\001VERSION\001"
    msg = Cinch::Message.new(raw, @bot)

    assert msg.ctcp?
    refute msg.action?
    assert_equal "VERSION", msg.ctcp_command
  end

  test "parses tags" do
    raw = "@key=value;flag :nick!user@host PRIVMSG #channel :msg"
    msg = Cinch::Message.new(raw, @bot)

    assert_equal({key: "value", flag: "flag"}, msg.tags)
  end

  test "parses statusmsg prefix" do
    # @#channel means to ops only
    raw = ":nick!user@host PRIVMSG @#channel :secret"
    msg = Cinch::Message.new(raw, @bot)

    assert_equal "o", msg.statusmsg_mode
    assert_equal "Channel(#channel)", msg.channel
  end
end
