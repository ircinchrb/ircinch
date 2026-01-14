require_relative "../../test_helper"
require "cinch/channel_list"
require "cinch/channel"

class ChannelListTest < TestCase
  class MockISupport
    def [](key)
      return :rfc1459 if key == "CASEMAPPING"
      nil
    end
  end

  class MockIRC
    def isupport
      MockISupport.new
    end
  end

  class MockBot
    attr_reader :irc
    def initialize
      @irc = MockIRC.new
    end
  end

  def setup
    @bot = MockBot.new
    @list = Cinch::ChannelList.new(@bot)
  end

  test "find returns nil if channel not in list" do
    assert_nil @list.find("missing")
  end

  test "find_ensured creates channel if missing" do
    c = @list.find_ensured("#channel")
    assert_instance_of Cinch::Channel, c
    assert_equal "#channel", c.name
  end

  test "find_ensured returns existing channel" do
    c1 = @list.find_ensured("#channel")
    c2 = @list.find_ensured("#channel")
    assert_same c1, c2
  end

  test "find returns existing channel (case insensitive)" do
    c1 = @list.find_ensured("#channel")
    c2 = @list.find("#CHANNEL")
    assert_same c1, c2
  end
  
  test "find_ensured returns existing channel (case insensitive)" do
    c1 = @list.find_ensured("#channel")
    c2 = @list.find_ensured("#CHANNEL")
    assert_same c1, c2
  end
end
