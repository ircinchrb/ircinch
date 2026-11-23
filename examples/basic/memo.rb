# frozen_string_literal: true

require_relative "../settings"

memos = {}

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_memo")
  end

  on :message do |m|
    next unless m.user

    nick = m.user.nick
    key = nick.irc_downcase(bot.irc.isupport["CASEMAPPING"])
    memo = synchronize(:memos) { memos.delete(key) }
    m.user.safe_send(memo) if memo
  end

  on :message, /\A!memo (\S+) (.+)\z/ do |m, nick, text|
    next unless m.user

    casemap = bot.irc.isupport["CASEMAPPING"]
    key = nick.irc_downcase(casemap)
    if [m.user.nick, bot.nick].any? { |name| name.irc_downcase(casemap) == key }
      m.reply "Choose another recipient."
      next
    end

    added = synchronize(:memos) do
      unless memos.key?(key)
        memos[key] = "Memo from #{m.user.nick}: #{text}"
        true
      end
    end
    m.safe_reply(added ? "Added memo for #{nick}." : "There is already a memo for #{nick}.")
  end
end

bot.start
