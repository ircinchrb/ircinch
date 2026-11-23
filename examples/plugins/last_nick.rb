# frozen_string_literal: true

require_relative "../settings"

class Nickchange
  include Cinch::Plugin

  listen_to :nick

  def listen(m)
    return if m.user == bot

    # This will send a PM to the user who changed their nick and inform
    # them of their old nick.
    m.reply "Your old nick was: #{m.user.last_nick}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_nick")
    c.plugins.plugins = [Nickchange]
  end
end

bot.start
