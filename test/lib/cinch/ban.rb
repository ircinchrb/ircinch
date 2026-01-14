# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/ban"
require "cinch/mask"
require "cinch/user"
require "cinch/exceptions"

# Polyfill if missing in test env (it might be aliased elsewhere in full app)

class BanTest < TestCase
  class MockUser
    attr_reader :mask
    def initialize(mask_str)
      @mask = Cinch::Mask.new(mask_str)
    end

    def nick
      @mask.nick
    end

    def user
      @mask.user
    end

    def host
      @mask.host
    end
  end

  test "initialize standard ban" do
    user = MockUser.new("nick!user@host")
    ban = Cinch::Ban.new("mask!*@*", user, Time.now)

    refute ban.extended
    assert_instance_of Cinch::Mask, ban.mask
    assert_equal "mask!*@*", ban.mask.to_s
    assert_equal user, ban.by
  end

  test "initialize extended ban" do
    user = MockUser.new("nick!user@host")
    ban = Cinch::Ban.new("$a:nick", user, Time.now)

    assert ban.extended
    assert_instance_of String, ban.mask
    assert_equal "$a:nick", ban.mask
  end

  test "match standard ban" do
    ban = Cinch::Ban.new("nick!*@*", nil, Time.now)

    target = MockUser.new("nick!other@host")
    assert ban.match(target)

    target2 = MockUser.new("other!other@host")
    refute ban.match(target2)
  end

  test "match extended ban raises UnsupportedFeature" do
    ban = Cinch::Ban.new("$a:nick", nil, Time.now)
    assert_raises(Cinch::Exceptions::UnsupportedFeature) do
      ban.match(MockUser.new("nick!user@host"))
    end
  end

  test "to_s returns mask string" do
    ban = Cinch::Ban.new("mask!*@*", nil, Time.now)
    assert_equal "mask!*@*", ban.to_s

    ban2 = Cinch::Ban.new("$a:nick", nil, Time.now)
    assert_equal "$a:nick", ban2.to_s
  end
end
