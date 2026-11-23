# frozen_string_literal: true

require_relative "../settings"

class MultiCommands
  include Cinch::Plugin

  match(/command1 (.+)\z/, method: :command1)
  match(/command2 (.+)\z/, method: :command2)
  match(/\Acommand3 (.+)\z/, use_prefix: false)

  def command1(m, arg)
    m.safe_reply "command1, arg: #{arg}"
  end

  def command2(m, arg)
    m.safe_reply "command2, arg: #{arg}"
  end

  def execute(m, arg)
    m.safe_reply "command3, arg: #{arg}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_multi")
    c.plugins.plugins = [MultiCommands]
  end
end

bot.start
