require "cgi"
require "ircinch"
require "open-uri"

# Automatically shorten URL's found in messages
# Using the tinyURL API

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
  end

  helpers do
    def shorten(url)
      url = URI.open("http://tinyurl.com/api-create.php?url=#{CGI.escape(url)}").parse
      (url == "Error") ? nil : url
    rescue OpenURI::HTTPError
      nil
    end
  end

  on :channel do |m|
    urls = URI.extract(m.message, "http")

    unless urls.empty?
      short_urls = urls.map { |url| shorten(url) }.compact

      unless short_urls.empty?
        m.reply short_urls.join(", ")
      end
    end
  end
end

bot.start
