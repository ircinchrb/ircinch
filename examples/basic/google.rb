# frozen_string_literal: true

require_relative "../settings"
require "uri"

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_goog")
  end

  helpers do
    def google_link(query)
      "https://www.google.com/search?#{URI.encode_www_form(q: query)}"
    end
  end

  on :message, /\A!google (.+)\z/ do |m, query|
    m.reply google_link(query)
  end
end

bot.start
