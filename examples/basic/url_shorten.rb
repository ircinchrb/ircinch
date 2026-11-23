# frozen_string_literal: true

require_relative "../settings"
require_relative "../tiny_url"

shortener = TinyURLClient.new(ENV.fetch("TINYURL_TOKEN"))

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_url")
  end

  on :message, /\A!shorten (\S+)\z/ do |m, url|
    m.safe_reply(shortener.shorten(url))
  end
end

bot.start
