require "ircinch"

class MultiCommands
  include Cinch::Plugin

  match(/command1 (.+)/, method: :command1)
  match(/command2 (.+)/, method: :command2)
  match(/^command3 (.+)/, use_prefix: false)

  def command1(m, arg)
    m.reply "command1, arg: #{arg}"
  end

  def command2(m, arg)
    m.reply "command2, arg: #{arg}"
  end

  def execute(m, arg)
    m.reply "command3, arg: #{arg}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "ircinch_multi"
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
    c.verbose = true
    c.plugins.plugins = [MultiCommands]
  end
end

bot.start
