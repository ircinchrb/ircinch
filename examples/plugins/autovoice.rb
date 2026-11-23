# frozen_string_literal: true

require_relative "../settings"

# Give the bot +o in the channel. A channel operator can toggle autovoice.
class Autovoice
  include Cinch::Plugin

  listen_to :join
  match(/autovoice (on|off)\z/)

  def initialize(bot)
    super
    @enabled_channels = {}
  end

  def listen(m)
    channel = m.channel
    enabled = synchronize(:autovoice) { @enabled_channels[channel] }
    channel.voice(m.user) if enabled && m.user != bot && channel.opped?(bot)
  end

  def execute(m, option)
    return unless m.user && m.channel&.opped?(m.user)

    enabled = option == "on"
    synchronize(:autovoice) { @enabled_channels[m.channel] = enabled }
    m.reply "Autovoice is now #{enabled ? "enabled" : "disabled"}."
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_pvoic")
    c.plugins.plugins = [Autovoice]
  end
end

bot.start
