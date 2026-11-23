# frozen_string_literal: true

require_relative "../settings"

class JoinPart
  include Cinch::Plugin

  match(/join ([#&][^\s,]+)\z/, method: :join)
  match(/part(?: ([#&][^\s,]+))?\z/, method: :part)

  def join(m, channel)
    bot.join(channel) if ExampleSettings.admin?(m)
  end

  def part(m, channel)
    channel ||= m.channel
    bot.part(channel) if channel && ExampleSettings.admin?(m)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_pjoin")
    c.plugins.plugins = [JoinPart]
  end
end

bot.start
