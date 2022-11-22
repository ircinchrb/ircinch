require "ircinch"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "IrCinchBot"
    c.channels = ["#cinch-bots"]
  end

  # Who should be able to access these plugins
  def admin
    "injekt"
  end

  helpers do
    def is_admin?(user)
      true if user.nick == admin
    end
  end

  on :message, /^!join (.+)/ do |m, channel|
    bot.join(channel) if is_admin?(m.user)
  end

  on :message, /^!part(?: (.+))?/ do |m, channel|
    # Part current channel if none is given
    channel ||= m.channel

    if channel
      bot.part(channel) if is_admin?(m.user)
    end
  end
end

bot.start
