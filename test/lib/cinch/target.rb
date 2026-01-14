# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/target"
require "cinch/helpers"

class MessageSplitTest < TestCase
  module MessageSplit
    MASK = "msg_split!~msg_split@an-irc-client.some-provider.net"
    COMMAND = "NOTICE"
    CHANNEL = "#msg_split_test"
    PREFIX = ":#{MASK} #{COMMAND} #{CHANNEL} :" # 78 bytes
    MAX_BYTE_SIZE = 510 - PREFIX.bytesize
  end

  test "A short text should not be split" do
    target = Cinch::Target.new(nil, nil)
    short_lorem_ipsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " \
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

    actual_chunks = target.__send__(:split_message,
      short_lorem_ipsum, MessageSplit::PREFIX,
      "... ", " ...")
    expected_chunks = [short_lorem_ipsum]

    assert(expected_chunks.all? { |string|
      string.length < MessageSplit::MAX_BYTE_SIZE
    })
    assert_equal(expected_chunks, actual_chunks)
  end

  test "A long single-byte text should be split at the correct position" do
    target = Cinch::Target.new(nil, nil)
    lorem_ipsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " \
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. " \
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris " \
      "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in " \
      "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " \
      "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " \
      "culpa qui officia deserunt mollit anim id est laborum."

    expected_chunks = [
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " \
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. " \
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris " \
      "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in " \
      "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " \
      "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " \
      "culpa qui officia deserunt mollit ...",

      "... anim id est laborum."
    ]
    actual_chunks = target.__send__(:split_message,
      lorem_ipsum, MessageSplit::PREFIX,
      "... ", " ...")

    assert(expected_chunks.all? { |string|
      string.length < MessageSplit::MAX_BYTE_SIZE
    })
    assert_equal(expected_chunks, actual_chunks)
  end

  test "A long multi-byte text should be split at the correct position" do
    target = Cinch::Target.new(nil, nil)
    japanese_text =
      "私はその人を常に先生と呼んでいた。だからここでもただ先生と書く" \
      "だけで本名は打ち明けない。これは世間を憚かる遠慮というよりも、" \
      "その方が私にとって自然だからである。私はその人の記憶を呼び起す" \
      "ごとに、すぐ「先生」といいたくなる。筆を執っても心持は同じ事で" \
      "ある。よそよそしい頭文字などはとても使う気にならない。"

    expected_chunks = [
      "私はその人を常に先生と呼んでいた。だからここでもただ先生と書く" \
      "だけで本名は打ち明けない。これは世間を憚かる遠慮というよりも、" \
      "その方が私にとって自然だからである。私はその人の記憶を呼び起す" \
      "ごとに、すぐ「先生」といいたくなる。筆を執っても心持は同じ事で" \
      "ある。よそよそしい頭文字などはとても ...",

      "... 使う気にならない。"
    ]
    actual_chunks = target.__send__(:split_message,
      japanese_text, MessageSplit::PREFIX,
      "... ", " ...")

    assert(expected_chunks.all? { |string|
      string.length < MessageSplit::MAX_BYTE_SIZE
    })
    assert_equal(expected_chunks, actual_chunks)
  end

  test "A very long multi-byte text should be split at the correct position" do
    target = Cinch::Target.new(nil, nil)
    japanese_text =
      "JAPANESE_TEXT:親譲りの無鉄砲で小供の時から損ばかりしている。" \
      "小学校に居る時分学校の二階から飛び降りて一週間ほど腰を抜かした" \
      "事がある。なぜそんな無闇をしたと聞く人があるかも知れぬ。別段深い理由" \
      "でもない。新築の二階から首を出していたら、同級生の一人が冗談に、" \
      "いくら威張っても、そこから飛び降りる事は出来まい。弱虫やーい。" \
      "と囃したからである。小使に負ぶさって帰って来た時、おやじが" \
      "大きな眼をして二階ぐらいから飛び降りて腰を抜かす奴があるかと" \
      "云ったから、この次は抜かさずに飛んで見せますと答えた。親類の" \
      "ものから西洋製のナイフを貰って奇麗な刃を日に翳して、友達に" \
      "見せていたら、一人が光る事は光るが切れそうもないと云った。"

    expected_chunks = [
      "JAPANESE_TEXT:親譲りの無鉄砲で小供の時から損ばかりしている。" \
      "小学校に居る時分学校の二階から飛び降りて一週間ほど腰を抜かした" \
      "事がある。なぜそんな無闇をしたと聞く人があるかも知れぬ。別段深い理由" \
      "でもない。新築の二階から首を出していたら、同級生の一人が冗談に、" \
      "いくら威張っても、そこから飛び降りる ...",

      "... 事は出来まい。弱虫やーい。" \
      "と囃したからである。小使に負ぶさって帰って来た時、おやじが" \
      "大きな眼をして二階ぐらいから飛び降りて腰を抜かす奴があるかと" \
      "云ったから、この次は抜かさずに飛んで見せますと答えた。親類の" \
      "ものから西洋製のナイフを貰って奇麗な刃を日に翳して、友達に" \
      "見せていたら、一人が ...",

      "... 光る事は光るが切れそうもないと云った。"
    ]
    actual_chunks = target.__send__(:split_message,
      japanese_text, MessageSplit::PREFIX,
      "... ", " ...")

    assert(expected_chunks.all? { |string|
      string.length < MessageSplit::MAX_BYTE_SIZE
    })
    assert_equal(expected_chunks, actual_chunks)
  end
end

class TargetTest < TestCase
  class MockIRC
    attr_reader :sends, :isupport
    def initialize
      @sends = []
      @isupport = {"CASEMAPPING" => :rfc1459, "CHANTYPES" => ["#"]}
    end
    def send(msg); @sends << msg; end
  end

  class MockBot
    attr_reader :irc, :config, :mask, :user_list, :channel_list
    def initialize
      @irc = MockIRC.new
      @config = OpenStruct.new
      @mask = "bot!user@host"
      @user_list = []
      @channel_list = []
    end
    
    def isupport
      @irc.isupport
    end
  end

  def setup
    @bot = MockBot.new
    @target = Cinch::Target.new("target", @bot)
  end

  test "send uses PRIVMSG by default" do
    @target.send("hello")
    assert_equal "PRIVMSG target :hello", @bot.irc.sends.last
  end

  test "send uses NOTICE when requested" do
    @target.send("hello", true)
    assert_equal "NOTICE target :hello", @bot.irc.sends.last
  end

  test "send splits long messages" do
    # 512 max - prefix...
    long_msg = "a" * 600
    @target.send(long_msg)
    
    assert @bot.irc.sends.size > 1
    full_sent = @bot.irc.sends.map { |s| s.split(" :").last }.join
    assert_equal long_msg, full_sent
  end

  test "safe_send sanitizes input" do
    # Sanitize removes newlines etc
    @target.safe_send("foo\nbar")
    # sanitize replaces \n with space or similar? Cinch::Helpers.sanitize
    # Let's verify what sent.
    assert_match "foobar", @bot.irc.sends.last
  end

  test "action sends CTCP" do
    @target.action("dances")
    assert_equal "PRIVMSG target :\001ACTION dances\001", @bot.irc.sends.last
  end

  test "ctcp sends CTCP" do
    @target.ctcp("VERSION")
    assert_equal "PRIVMSG target :\001VERSION\001", @bot.irc.sends.last
  end
  
  test "comparison" do
    t1 = Cinch::Target.new("foo", @bot)
    t2 = Cinch::Target.new("FOO", @bot)
    assert_equal t1, t2
  end

  test "concretize looks up channel" do
    t = Cinch::Target.new("#chan", @bot)
    
    # Mock channel list lookup
    class << @bot.channel_list
      def find_ensured(name); :found_channel; end
    end
    
    assert_equal :found_channel, t.concretize
  end

  test "concretize looks up user" do
    t = Cinch::Target.new("user", @bot)
    
    # Mock user list lookup
    class << @bot.user_list
      def find_ensured(name); :found_user; end
    end
    
    assert_equal :found_user, t.concretize
  end

  test "safe_send strips formatting" do
    # \x03 is color code
    @target.safe_send("foo\x03bar")
    assert_equal "PRIVMSG target :foobar", @bot.irc.sends.last
  end

  test "notice sends NOTICE" do
    @target.notice("foo")
    assert_equal "NOTICE target :foo", @bot.irc.sends.last
  end

  test "safe_notice sanitizes input" do
    @target.safe_notice("foo\x03bar")
    assert_equal "NOTICE target :foobar", @bot.irc.sends.last
  end
  
  test "safe_action sanitizes input" do
    @target.safe_action("dances\x03")
    assert_equal "PRIVMSG target :\001ACTION dances\001", @bot.irc.sends.last
  end
end
