# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/plugin"

module Cinch
  class CinchTestPluginWithoutName
    include Cinch::Plugin
  end
end

class PluginTest < TestCase
  def setup
    @bot = Cinch::Bot.new {
      loggers.clear
    }
    @plugin = Class.new { include Cinch::Plugin }
    @bot.config.plugins.options = {@plugin => {key: :value}}

    @plugin.plugin_name = "testplugin"
    @plugin_instance = @plugin.new(@bot)
  end

  test "should be able to specify matchers" do
    @plugin.match(/pattern/) # standard:disable Performance/RedundantMatch
    matcher = @plugin.matchers.last

    assert_equal(1, @plugin.matchers.size, "Should not forget existing matchers")
    assert_equal Cinch::Plugin::ClassMethods::Matcher.new(/pattern/, true, true, :execute, nil, nil, nil, nil, false), matcher

    matcher = @plugin.match(/pattern/, use_prefix: false, use_suffix: false, method: :some_method)
    assert_equal Cinch::Plugin::ClassMethods::Matcher.new(/pattern/, false, false, :some_method, nil, nil, nil, nil, false), matcher
  end

  test "should be able to listen to events" do
    @plugin.listen_to(:event1, :event2)
    @plugin.listen_to(:event3, method: :some_method)

    listeners = @plugin.listeners
    assert_equal 3, listeners.size
    assert_equal [:event1, :event2, :event3], listeners.map(&:event)
    assert_equal [:listen, :listen, :some_method], listeners.map(&:method)
  end

  test "should be able to create CTCP commands" do
    @plugin.ctcp("FOO")
    @plugin.ctcp("BAR")

    assert_equal 2, @plugin.ctcps.size
    assert_equal ["FOO", "BAR"], @plugin.ctcps
  end

  test "CTCP commands should always be uppercase" do
    @plugin.ctcp("foo")
    assert_equal "FOO", @plugin.ctcps.last
  end

  test "should return an empty array of timers" do
    assert_equal [], @plugin.timers
  end

  test "should return an empty array of listeners" do
    assert_equal [], @plugin.listeners
  end

  test "should return an empty array of CTCPs" do
    assert_equal [], @plugin.ctcps
  end

  test "should be able to set timers" do
    @plugin.timer(1, method: :foo)
    @plugin.timer(2, method: :bar, threaded: false)

    timers = @plugin.timers
    assert_equal 2, timers.size
    assert_equal [1, 2], timers.map(&:interval)
    assert_equal [:foo, :bar], timers.map { |t| t.options[:method] }
    assert_equal [true, false], timers.map { |t| t.options[:threaded] }
  end

  test "should be able to register hooks" do
    @plugin.hook(:pre)
    @plugin.hook(:post, for: [:match])
    @plugin.hook(:post, method: :some_method)

    hooks = @plugin.hooks.values.flatten
    assert_equal [:pre, :post, :post], hooks.map(&:type)
    assert_equal [:match], hooks[1].for
    assert_equal :some_method, hooks.last.method
    assert_equal :hook, hooks.first.method
  end

  test "should have access to plugin configuration" do
    assert_equal :value, @plugin_instance.config[:key]
  end

  test "should be able to set a prefix with a block" do
    block = lambda { |m| "^" }
    @plugin.prefix = block
    assert_equal block, @plugin.prefix
  end

  test "should be able to set a suffix with a block" do
    block = lambda { |m| "^" }
    @plugin.suffix = block
    assert_equal block, @plugin.suffix
  end

  test "should support `set(key, value)`" do
    @plugin.set :help, "some help message"
    @plugin.set :prefix, "some prefix"
    @plugin.set :suffix, "some suffix"
    @plugin.set :plugin_name, "some plugin"
    @plugin.set :react_on, :event1

    assert_equal "some help message", @plugin.help
    assert_equal "some prefix", @plugin.prefix
    assert_equal "some suffix", @plugin.suffix
    assert_equal "some plugin", @plugin.plugin_name
    assert_equal :event1, @plugin.react_on
  end

  test "should support `set(key => value, key => value, ...)`" do
    @plugin.set(help: "some help message",
      prefix: "some prefix",
      suffix: "some suffix",
      plugin_name: "some plugin",
      react_on: :event1)

    assert_equal "some help message", @plugin.help
    assert_equal "some prefix", @plugin.prefix
    assert_equal "some suffix", @plugin.suffix
    assert_equal "some plugin", @plugin.plugin_name
    assert_equal :event1, @plugin.react_on
  end

  test "should support `self.key = value`" do
    @plugin.help = "some help message"
    @plugin.prefix = "some prefix"
    @plugin.suffix = "some suffix"
    @plugin.plugin_name = "some plugin"
    @plugin.react_on = :event1

    assert_equal "some help message", @plugin.help
    assert_equal "some prefix", @plugin.prefix
    assert_equal "some suffix", @plugin.suffix
    assert_equal "some plugin", @plugin.plugin_name
    assert_equal :event1, @plugin.react_on
  end

  test "should support querying attributes" do
    @plugin.plugin_name = "foo"
    @plugin.help = "I am a help message"
    @plugin.prefix = "^"
    @plugin.suffix = "!"
    @plugin.react_on = :event1

    assert_equal "foo", @plugin.plugin_name
    assert_equal "I am a help message", @plugin.help
    assert_equal "^", @plugin.prefix
    assert_equal "!", @plugin.suffix
    assert_equal :event1, @plugin.react_on
  end

  test "should have a default name" do
    assert_equal "cinchtestpluginwithoutname", Cinch::CinchTestPluginWithoutName.plugin_name
  end

  test "should check for the right number of arguments for `set`" do
    assert_raises(ArgumentError) { @plugin.set }
    assert_raises(ArgumentError) { @plugin.set(1, 2, 3) }
  end
end

class PluginStructureTest < TestCase
  class TestPlugin
    include Cinch::Plugin
    
    match "foo"
    listen_to :channel
    timer 5, method: :my_timer
    hook :pre, method: :my_hook
  end

  test "match stores matcher" do
    matchers = TestPlugin.matchers
    assert_equal 1, matchers.size
    assert_equal "foo", matchers.first.pattern
    assert matchers.first.use_prefix
  end

  test "listen_to stores listener" do
    listeners = TestPlugin.listeners
    assert_equal 1, listeners.size
    assert_equal :channel, listeners.first.event
  end

  test "timer stores timer struct" do
    timers = TestPlugin.timers
    assert_equal 1, timers.size
    assert_equal 5, timers.first.interval
    assert_equal :my_timer, timers.first.options[:method]
  end

  test "hook stores hook" do
    hooks = TestPlugin.hooks
    assert_equal 1, hooks[:pre].size
    assert_equal :my_hook, hooks[:pre].first.method
  end
  
  test "plugin_name inference" do
    assert_equal "testplugin", TestPlugin.plugin_name
  end
  
  test "manual plugin_name" do
    class NamedPlugin
      include Cinch::Plugin
      self.plugin_name = "custom"
    end
    assert_equal "custom", NamedPlugin.plugin_name
  end
end


class PluginLifecycleTest < TestCase
  def setup
    @bot = Cinch::Bot.new
    @bot.loggers.level = :fatal
  end

  test "registers matchers with the bot" do
    plugin_class = Class.new { include Cinch::Plugin; match "foo" }
    plugin_class.plugin_name = "test"
    
    plugin_class.new(@bot)
    
    handler = @bot.handlers.detect { |h| h.pattern.pattern == "foo" }
    refute_nil handler
  end

  test "registers listeners with the bot" do
    plugin_class = Class.new { include Cinch::Plugin; listen_to :join }
    plugin_class.plugin_name = "listener_test"
    plugin_class.new(@bot)
    
    handler = @bot.handlers.detect { |h| h.event == :join }
    refute_nil handler
  end

  test "aborts execution if pre-hook returns false" do
    plugin_class = Class.new do
      include Cinch::Plugin
      hook :pre, method: :my_hook
      match "foo"
      
      attr_reader :hook_called, :match_called
      
      def my_hook(m)
        @hook_called = true
        false # Abort
      end
      
      def execute(m)
        @match_called = true
      end
    end
    plugin_class.plugin_name = "hook_test"
    
    plugin = plugin_class.new(@bot)
    
    # Dispatch a message that matches "foo"
    # We need to manually invoke the handler found in bot
    handler = @bot.handlers.detect { |h| h.pattern.pattern == "foo" }
    
    msg = OpenStruct.new(params: []) # dummy message
    
    t = handler.call(msg, [], [])
    t.join
    
    assert plugin.hook_called
    refute plugin.match_called
  end

  test "unregister removes handlers" do
    plugin_class = Class.new { include Cinch::Plugin; match "foo" }
    plugin_class.plugin_name = "unregister_test"
    plugin = plugin_class.new(@bot)
    
    assert_equal 1, @bot.handlers.count { |h| h.pattern.pattern == "foo" }
    
    plugin.unregister
    
    assert_equal 0, @bot.handlers.count { |h| h.pattern.pattern == "foo" }
  end
  
  test "required options enforcement" do
     plugin_class = Class.new { 
       include Cinch::Plugin
       self.plugin_name = "options_test"
       self.required_options = [:required_key]
     }
     
     # Spy on loggers to check for warning
     log_output = []
     @bot.loggers.define_singleton_method(:warn) { |msg| log_output << msg }
     
     plugin = plugin_class.new(@bot)
     
     # Should warn
     assert_includes log_output.join, "Could not register plugin"
     
     # Should not register anything (no matchers anyway, but check lifecycle)
     # Since it returns early, handlers list should be empty (though new instance empty anyway)
     assert_empty plugin.handlers
  end
end
