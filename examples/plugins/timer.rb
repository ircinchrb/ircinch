# frozen_string_literal: true

require_relative "../settings"

class TimedPlugin
  include Cinch::Plugin

  timer 5, method: :timed
  def timed
    bot.channels.first&.send("5 seconds have passed")
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_timer")
    c.plugins.plugins = [TimedPlugin]
  end
end

bot.start
