require "ircinch"

class TimedPlugin
  include Cinch::Plugin

  timer 5, method: :timed
  def timed
    Channel("#ircinch-bots").send "5 seconds have passed"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "ircinch_timer"
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
    c.verbose = true
    c.plugins.plugins = [TimedPlugin]
  end
end

bot.start
