require "ircinch"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "IrCinchBot"
    c.channels = ["#ircinch-bots"]
  end

  on :message, /^!msg (.+?) (.+)/ do |m, who, text|
    User(who).send text
  end
end

bot.start
