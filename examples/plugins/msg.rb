require "ircinch"

class Messenger
  include Cinch::Plugin

  match(/msg (.+?) (.+)/)
  def execute(m, receiver, message)
    User(receiver).send(message)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "IrCinchBot"
    c.channels = ["#ircinch-bots"]
    c.plugins.plugins = [Messenger]
  end
end

bot.start
