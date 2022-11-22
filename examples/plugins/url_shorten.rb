require "cgi"
require "ircinch"
require "open-uri"

class TinyURL
  include Cinch::Plugin

  listen_to :channel

  def shorten(url)
    url = URI.parse("http://tinyurl.com/api-create.php?url=#{CGI.escape(url)}").open
    (url == "Error") ? nil : url
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    urls = URI.extract(m.message, "http")
    short_urls = urls.map { |url| shorten(url) }.compact
    unless short_urls.empty?
      m.reply short_urls.join(", ")
    end
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
    c.plugins.plugins = [TinyURL]
  end
end

bot.start
