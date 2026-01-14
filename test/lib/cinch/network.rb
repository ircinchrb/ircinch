# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/network"

class NetworkTest < TestCase
  test "unknown_network? returns true for :unknown" do
    n = Cinch::Network.new(:unknown, :unknown)
    assert n.unknown_network?
    assert n.unknown_ircd?
  end

  test "default_messages_per_second" do
    freenode = Cinch::Network.new(:freenode, :unknown)
    assert_in_delta 0.7, freenode.default_messages_per_second

    other = Cinch::Network.new(:other, :unknown)
    assert_in_delta 0.5, other.default_messages_per_second
  end

  test "default_server_queue_size" do
    quakenet = Cinch::Network.new(:quakenet, :unknown)
    assert_equal 40, quakenet.default_server_queue_size

    other = Cinch::Network.new(:other, :unknown)
    assert_equal 10, other.default_server_queue_size
  end

  test "owner_list_mode" do
    unreal = Cinch::Network.new(:unknown, :unreal)
    assert_equal "q", unreal.owner_list_mode

    other = Cinch::Network.new(:unknown, :other)
    assert_nil other.owner_list_mode
  end
end
