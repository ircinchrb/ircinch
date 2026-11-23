# frozen_string_literal: true

require_relative "../settings"
require "uri"

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_urban")
  end

  on :message, /\A!urban (.+)\z/ do |m, term|
    m.reply "https://www.urbandictionary.com/define.php?#{URI.encode_www_form(term: term)}"
  end
end

bot.start
