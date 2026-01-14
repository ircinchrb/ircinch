# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/user_list"

class UserListTest < TestCase
  class MockNetwork
    def whois_only_one_argument?
      false
    end
  end

  class MockIRC
    attr_reader :isupport, :network, :socket
    def initialize
      @isupport = {"CASEMAPPING" => :rfc1459}
      @network = MockNetwork.new
      @socket = Object.new # dummy
    end

    def send(msg)
      # dummy
    end
  end

  class MockLoggerList
    def warn(*args)
    end

    def debug(*args)
    end

    def error(*args)
    end
  end

  class MockBot
    attr_reader :nick, :irc, :loggers
    def initialize
      @nick = "bot"
      @irc = MockIRC.new
      @loggers = MockLoggerList.new
    end
  end

  def setup
    @bot = MockBot.new
    @user_list = Cinch::UserList.new(@bot)
  end

  test "find_ensured with 1 argument creates new user" do
    user = @user_list.find_ensured("nick")
    assert_instance_of Cinch::User, user
    assert_equal "nick", user.nick
  end

  test "find_ensured with 3 arguments creates new user with details" do
    user = @user_list.find_ensured("user", "nick", "host")
    assert_instance_of Cinch::User, user
    assert_equal "nick", user.nick
    assert_equal "user", user.user
    assert_equal "host", user.host
  end

  test "find_ensured returns existing user" do
    user1 = @user_list.find_ensured("nick")
    user2 = @user_list.find_ensured("nick")
    assert_same user1, user2
  end

  test "find_ensured updates user/host if provided" do
    user = @user_list.find_ensured("nick")

    # Patch refresh to avoid blocking network call
    def user.refresh
      sync(:user, nil, true)
      sync(:host, nil, true)
    end

    assert_nil user.user
    assert_nil user.host

    @user_list.find_ensured("newuser", "nick", "newhost")
    assert_equal "newuser", user.user
    assert_equal "newhost", user.host
  end

  test "find_ensured downcases nick via irc_downcase" do
    user1 = @user_list.find_ensured("NICK")
    user2 = @user_list.find_ensured("nick")
    assert_same user1, user2
    assert_equal "NICK", user1.nick
  end

  test "find_ensured returns bot if nick matches bot" do
    user = @user_list.find_ensured("bot")
    assert_same @bot, user
  end

  test "find returns existing user" do
    @user_list.find_ensured("nick")
    user = @user_list.find("nick")
    assert_equal "nick", user.nick
  end

  test "find returns nil for unknown user" do
    assert_nil @user_list.find("unknown")
  end

  test "find returns bot if nick matches bit" do
    assert_same @bot, @user_list.find("bot")
  end

  test "update_nick updates cache key" do
    user = @user_list.find_ensured("oldnick")
    # Simulate user changing nick (User#update_nick calls UserList#update_nick)
    # But since we are testing UserList, we can just call update_nick directly after changing user's nick manually if possible,
    # or rely on User#update_nick logic.
    # User#update_nick calls @bot.user_list.update_nick(self)

    # We need to stub User#last_nick because it's used in update_nick
    # But User#last_nick is set in User#update_nick.
    # So let's just trigger User#update_nick if we can, but User expects a real bot potentially.
    # Let's verify User#update_nick logic:
    # def update_nick(new_nick)
    #   @last_nick, @name = @name, new_nick
    #   unsync(:authname)
    #   @bot.user_list.update_nick(self)
    # end

    # So we can just call user.update_nick("newnick") and it should callback to @user_list.
    # But checking if our mock bot has user_list reference? No, it doesn't.
    # User uses @bot reference passed in constructor.
    # So we need to add user_list accessor to MockBot.

    def @bot.user_list=(ul)
      @user_list = ul
    end

    def @bot.user_list
      @user_list
    end
    @bot.user_list = @user_list

    user.update_nick("newnick")

    assert_nil @user_list.find("oldnick")
    assert_equal user, @user_list.find("newnick")
  end

  test "delete removes user from cache" do
    user = @user_list.find_ensured("nick")
    @user_list.delete(user)
    assert_nil @user_list.find("nick")
  end
end
