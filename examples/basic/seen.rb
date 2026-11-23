# frozen_string_literal: true

require_relative "../settings"

last_messages = {}

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_seen")
  end

  on :message do |m|
    next unless m.channel && m.user && !m.ctcp? && !m.statusmsg_mode

    nick = m.user.nick
    key = [m.channel, nick.irc_downcase(bot.irc.isupport["CASEMAPPING"])]
    entry = "[#{m.time.asctime}] #{nick} said #{m.message}"
    synchronize(:seen) { last_messages[key] = entry }
  end

  on :message, /\A!seen (\S+)\z/ do |m, nick|
    next unless m.channel

    key = [m.channel, nick.irc_downcase(bot.irc.isupport["CASEMAPPING"])]
    entry = synchronize(:seen) { last_messages[key] }
    m.safe_reply(entry || "I haven't seen #{nick} in this channel.")
  end
end

bot.start
