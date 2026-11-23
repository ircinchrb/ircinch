# frozen_string_literal: true

require_relative "../settings"

# Give the bot +o in the channel. A channel operator can toggle autovoice.
enabled_channels = {}

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_voice")
  end

  on :join do |m|
    channel = m.channel
    enabled = synchronize(:autovoice) { enabled_channels[channel] }
    channel.voice(m.user) if enabled && m.user != bot && channel.opped?(bot)
  end

  on :message, /\A!autovoice (on|off)\z/ do |m, option|
    next unless m.user && m.channel&.opped?(m.user)

    enabled = option == "on"
    synchronize(:autovoice) { enabled_channels[m.channel] = enabled }
    m.reply "Autovoice is now #{enabled ? "enabled" : "disabled"}."
  end
end

bot.start
