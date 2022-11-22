require "ircinch"

class SomeCommand
  include Cinch::Plugin

  set :prefix, /^~/
  match "somecommand"

  def execute(m)
    m.reply "Successful"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
    c.plugins.plugins = [SomeCommand]
  end
end

bot.start
