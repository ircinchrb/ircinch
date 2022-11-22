require "cgi"
require "ircinch"
require "nokogiri"
require "open-uri"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "MrIrCinch"
    c.channels = ["#ircinch-bots"]
  end

  helpers do
    # Extremely basic method, grabs the first result returned by Google
    # or "No results found" otherwise
    def google(query)
      url = "http://www.google.com/search?q=#{CGI.escape(query)}"
      res = Nokogiri.HTML(URI.parse(url).open).at("h3.r")

      title = res.text
      link = res.at("a")[:href]
      desc = res.at("./following::div").children.first.text
    rescue
      "No results found"
    else
      CGI.unescape_html "#{title} - #{desc} (#{link})"
    end
  end

  on :message, /^!google (.+)/ do |m, query|
    m.reply google(query)
  end
end

bot.start
