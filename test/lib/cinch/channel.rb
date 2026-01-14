require_relative "../../test_helper"
require "cinch/channel"
require "cinch/user"

class ChannelTest < TestCase
  class MockNetwork
    attr_reader :owner_list_mode
    def initialize
      @owner_list_mode = "q"
    end
  end

  class MockISupport
    def [](key)
      case key
      when "TOPICLEN" then 20
      when "KICKLEN" then 20
      end
    end
  end

  class MockIRC
    attr_reader :sent, :network, :isupport
    def initialize
      @sent = []
      @network = MockNetwork.new
      @isupport = MockISupport.new
    end
    
    def send(msg)
      @sent << msg
    end
  end

  class MockLoggerList
    def warn(msg); end
    def debug(msg); end
  end

  class MockBot
    attr_reader :irc, :loggers, :config
    def initialize
      @irc = MockIRC.new
      @loggers = MockLoggerList.new
      @strict = false
      @config = OpenStruct.new
    end
    def strict?; @strict; end
    def strict=(val); @strict = val; end
    def identifying?; false; end
    def mask; "bot!user@host"; end
  end
  
  # Helper to mock Cinch::Helpers (used by Channel)
  class Wrapper
    include Cinch::Helpers
    def initialize(bot)
      @bot = bot
    end
  end

  def setup
    @bot = MockBot.new
    @channel = Cinch::Channel.new("#channel", @bot)
  end

  test "initialize sets basic attributes" do
    assert_equal "#channel", @channel.name
    assert_empty @channel.instance_variable_get(:@users)
    assert_empty @channel.instance_variable_get(:@bans)
    assert_empty @channel.instance_variable_get(:@modes)
    refute @channel.attribute_synced?(:users)
  end

  test "add_user adds user and sets bot as in_channel" do
    user = Cinch::User.new("user", @bot)
    @channel.add_user(user, ["o"])
    
    assert @channel.has_user?(user)
    assert @channel.opped?(user)
    refute @channel.voiced?(user)
    
    # Check bot in_channel logic (private API, but behavioral)
    # The sync logic depends on @in_channel. 
    # add_user(bot) sets in_channel = true
    @channel.add_user(@bot, [])
    # We can check variable via instance_variable_get or behavior
    assert @channel.instance_variable_get(:@in_channel)
  end

  test "remove_user removes user" do
    user = Cinch::User.new("user", @bot)
    @channel.add_user(user, [])
    @channel.remove_user(user)
    refute @channel.has_user?(user)
  end
  
  test "sync_modes sends requests" do
    @channel.sync_modes
    assert_includes @bot.irc.sent, "WHO #channel"
    assert_includes @bot.irc.sent, "MODE #channel +b"
    assert_includes @bot.irc.sent, "MODE #channel +q" # owner list
  end

  test "kick sends kick command" do
    @channel.kick("baduser", "bye")
    assert_includes @bot.irc.sent, "KICK #channel baduser :bye"
  end
  
  test "kick raises if reason too long in strict mode" do
    @bot.strict = true
    # Limit is 20
    assert_raises(Cinch::Exceptions::KickReasonTooLong) do
      @channel.kick("user", "this reason is definitely way too long for limits")
    end
  end

  test "topic= sends topic command" do
    @channel.topic = "new topic"
    assert_includes @bot.irc.sent, "TOPIC #channel :new topic"
  end

  test "topic= raises if too long in strict mode" do
    @bot.strict = true
    # limit 20
    assert_raises(Cinch::Exceptions::TopicTooLong) do
      @channel.topic = "this topic is definitely way too long"
    end
  end
  
  test "invite sends invite" do
    @channel.invite("friend")
    assert_includes @bot.irc.sent, "INVITE friend #channel"
  end

  test "mode setters send commands" do
    @channel.invite_only = true
    assert_includes @bot.irc.sent, "MODE #channel +i"
    
    @bot.irc.sent.clear
    @channel.limit = 10
    assert_includes @bot.irc.sent, "MODE #channel +l 10"
    
    @bot.irc.sent.clear
    @channel.limit = nil
    assert_includes @bot.irc.sent, "MODE #channel -l"
  end
  
  test "user group getters" do
    u1 = Cinch::User.new("op", @bot)
    u2 = Cinch::User.new("voice", @bot)
    
    @channel.add_user(u1, ["o"])
    @channel.add_user(u2, ["v"])
    
    assert_includes @channel.ops, u1
    refute_includes @channel.ops, u2
    
    assert_includes @channel.voiced, u2
    refute_includes @channel.voiced, u1
  end

  test "ban sends mode +b" do
    # We can mock mask or use string
    # Ban.new logic might be involved but Channel#ban(target) calls Mask.from(target)
    # If we pass string, Mask.from uses it.
    @channel.ban("badguy!*@*")
    assert_includes @bot.irc.sent, "MODE #channel +b badguy!*@*"
  end

  test "unban sends mode -b" do
    @channel.unban("badguy!*@*")
    assert_includes @bot.irc.sent, "MODE #channel -b badguy!*@*"
  end

  test "op/deop/voice/devoice sends modes" do
    u = Cinch::User.new("user", @bot)
    
    @channel.op(u)
    assert_includes @bot.irc.sent, "MODE #channel +o user"
    
    @bot.irc.sent.clear
    @channel.deop(u)
    assert_includes @bot.irc.sent, "MODE #channel -o user"
    
    @bot.irc.sent.clear
    @channel.voice(u)
    assert_includes @bot.irc.sent, "MODE #channel +v user"
    
    @bot.irc.sent.clear
    @channel.devoice(u)
    assert_includes @bot.irc.sent, "MODE #channel -v user"
  end

  test "part sends PART" do
    @channel.part("bye")
    assert_includes @bot.irc.sent, "PART #channel :bye"
  end

  test "join sends JOIN" do
    @channel.join("key")
    assert_includes @bot.irc.sent, "JOIN #channel key"
    
    @bot.irc.sent.clear
    @channel.join
    assert_includes @bot.irc.sent, "JOIN #channel"
  end

  test "remove sends REMOVE" do
    u = Cinch::User.new("user", @bot)
    @channel.remove(u, "get out")
    assert_includes @bot.irc.sent, "REMOVE #channel user :get out"
  end

  test "send strips formatting if +c mode set" do
    @channel.instance_variable_get(:@modes)["c"] = true
    @channel.send("\x0304colored\x03")
    
    # Target#send -> @bot.irc.send "PRIVMSG ..."
    # We verify that it called @bot.irc.send with stripped text
    # But Channel#send calls super, which is Target#send.
    # Target#send calls @bot.irc.send.
    # Wait, Target is not in this test file, we mock @bot.irc.send?
    # Actually Channel inherits Target.
    # Target#send implementation:
    # def send(text, notice = false)
    #   ...
    #   @bot.irc.send("PRIVMSG ... :#{text}")
    # end
    
    # Check if we can intercept implicit super call?
    # We rely on @bot.irc.sent getting the message.
    
    msg = @bot.irc.sent.last
    assert_match(/PRIVMSG #channel :colored/, msg)
    refute_match(/\x03/, msg)
  end
end
