# frozen_string_literal: true

require_relative "../settings"
require "uri"

class Google
  include Cinch::Plugin

  match(/google (.+)\z/)

  def execute(m, query)
    m.reply "https://www.google.com/search?#{URI.encode_www_form(q: query)}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_pgoog")
    c.plugins.plugins = [Google]
  end
end

bot.start
