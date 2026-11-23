# frozen_string_literal: true

require_relative "../settings"
require_relative "../tiny_url"

class URLShortener
  include Cinch::Plugin

  set :required_options, [:token]
  match(/shorten (\S+)\z/)

  def initialize(bot)
    super
    @shortener = TinyURLClient.new(config.fetch(:token))
  end

  def execute(m, url)
    m.safe_reply(@shortener.shorten(url))
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_purl")
    c.plugins.plugins = [URLShortener]
    c.plugins.options[URLShortener] = {token: ENV.fetch("TINYURL_TOKEN")}
  end
end

bot.start
