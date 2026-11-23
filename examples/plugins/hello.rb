# frozen_string_literal: true

require_relative "../settings"

class Hello
  include Cinch::Plugin

  match "hello"

  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_phelo")
    c.plugins.plugins = [Hello]
  end
end

bot.start
