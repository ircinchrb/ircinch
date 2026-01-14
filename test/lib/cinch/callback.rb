require_relative "../../test_helper"
require "cinch/callback"

class CallbackTest < TestCase
  class MockBot
    attr_reader :synced, :loggers
    def initialize
      @synced = false
      @loggers = []
    end
    def synchronize(name)
      @synced = true
      yield
    end
  end

  def setup
    @bot = MockBot.new
    @cb = Cinch::Callback.new(@bot)
  end

  test "initialize sets bot" do
    assert_equal @bot, @cb.bot
  end

  test "synchronize delegates to bot" do
    executed = false
    @cb.synchronize(:foo) { executed = true }
    assert executed
    assert @bot.synced
  end
end
