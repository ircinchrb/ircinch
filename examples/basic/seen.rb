require "ircinch"

class Seen < Struct.new(:who, :where, :what, :time)
  def to_s
    "[#{time.asctime}] #{who} was seen in #{where} saying #{what}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
  end

  def users
    {}
  end

  # Only log channel messages
  on :channel do |m|
    users[m.user.nick] = Seen.new(m.user.nick, m.channel, m.message, Time.new)
  end

  on :channel, /^!seen (.+)/ do |m, nick|
    if nick == bot.nick
      m.reply "That's me!"
    elsif nick == m.user.nick
      m.reply "That's you!"
    elsif users.key?(nick)
      m.reply users[nick].to_s
    else
      m.reply "I haven't seen #{nick}"
    end
  end
end

bot.start
