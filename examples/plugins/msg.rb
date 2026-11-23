# frozen_string_literal: true

require_relative "../settings"

class Messenger
  include Cinch::Plugin

  match(/msg ([^\s,#&]+) (.+)\z/)
  def execute(m, receiver, message)
    User(receiver).safe_send(message) if ExampleSettings.admin?(m)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_pmsg")
    c.plugins.plugins = [Messenger]
  end
end

bot.start
