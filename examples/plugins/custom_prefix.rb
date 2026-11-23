# frozen_string_literal: true

require_relative "../settings"

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
    ExampleSettings.configure(c, "irc_pref")
    c.plugins.plugins = [SomeCommand]
  end
end

bot.start
