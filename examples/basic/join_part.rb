# frozen_string_literal: true

require_relative "../settings"

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_join")
  end

  on :message, /\A!join ([#&][^\s,]+)\z/ do |m, channel|
    bot.join(channel) if ExampleSettings.admin?(m)
  end

  on :message, /\A!part(?: ([#&][^\s,]+))?\z/ do |m, channel|
    channel ||= m.channel
    bot.part(channel) if channel && ExampleSettings.admin?(m)
  end
end

bot.start
