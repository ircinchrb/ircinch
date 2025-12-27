require "cgi"
require "ircinch"
require "nokogiri"
require "open-uri"

class Google
  include Cinch::Plugin

  match(/google (.+)/)

  def search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri.HTML(URI.parse(url).open).at("h3.r")

    title = res.text
    link = res.at("a")[:href]
    desc = res.at("./following::div").children.first.text
    CGI.unescape_html "#{title} - #{desc} (#{link})"
  rescue
    "No results found"
  end

  def execute(m, query)
    m.reply(search(query))
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "MrIrCinch"
    c.channels = ["#ircinch-bots"]
    c.plugins.plugins = [Google]
  end
end

bot.start
