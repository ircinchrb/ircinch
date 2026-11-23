# frozen_string_literal: true

require_relative "../settings"

class Seen
  include Cinch::Plugin

  listen_to :message
  match(/seen (\S+)\z/)

  def initialize(bot)
    super
    @last_messages = {}
  end

  def listen(m)
    return unless m.channel && m.user && !m.ctcp? && !m.statusmsg_mode

    nick = m.user.nick
    entry = "[#{m.time.asctime}] #{nick} said #{m.message}"
    synchronize(:seen) { @last_messages[seen_key(m.channel, nick)] = entry }
  end

  def execute(m, nick)
    return unless m.channel

    entry = synchronize(:seen) { @last_messages[seen_key(m.channel, nick)] }
    m.safe_reply(entry || "I haven't seen #{nick} in this channel.")
  end

  private

  def seen_key(channel, nick)
    [channel, nick.irc_downcase(bot.irc.isupport["CASEMAPPING"])]
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_pseen")
    c.plugins.plugins = [Seen]
  end
end

bot.start
