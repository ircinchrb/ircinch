# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/plugin_list"

class PluginListTest < TestCase
  class MockBot; end

  class MockPlugin
    attr_reader :bot, :unregistered
    def initialize(bot)
      @bot = bot
      @unregistered = false
    end

    def unregister
      @unregistered = true
    end
  end

  def setup
    @bot = MockBot.new
    @list = Cinch::PluginList.new(@bot)
  end

  test "register_plugin adds instance" do
    @list.register_plugin(MockPlugin)
    assert_equal 1, @list.size
    assert_instance_of MockPlugin, @list.first
    assert_equal @bot, @list.first.bot
  end

  test "register_plugins adds multiple" do
    @list.register_plugins([MockPlugin, MockPlugin])
    assert_equal 2, @list.size
  end

  test "unregister_plugin removes and calls unregister" do
    @list.register_plugin(MockPlugin)
    plugin = @list.first

    @list.unregister_plugin(plugin)
    assert_empty @list
    assert plugin.unregistered
  end

  test "unregister_all removes all" do
    @list.register_plugins([MockPlugin, MockPlugin])
    assert_equal 2, @list.size

    @list.unregister_all
    assert_empty @list
  end
end
