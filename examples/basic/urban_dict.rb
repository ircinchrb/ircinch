require "cgi"
require "ircinch"
require "nokogiri"
require "open-uri"

# This bot connects to urban dictionary and returns the first result
# for a given query, replying with the result directly to the sender

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "MrIrCinch"
    c.channels = ["#ircinch-bots"]
  end

  helpers do
    # This method assumes everything will go ok, it's not the best method
    # of doing this *by far* and is simply a helper method to show how it
    # can be done.. it works!
    def urban_dict(query)
      url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
      CGI.unescape_html Nokogiri::HTML(URI.parse(url)).open.css("div.meaning").first.text.gsub(/\s+/, " ").strip
    rescue
      nil
    end
  end

  on :message, /^!urban (.+)/ do |m, term|
    m.reply(urban_dict(term) || "No results found", true)
  end
end

bot.start

# injekt> !urban cinch
# MrIrCinch> injekt: describing an action that's extremely easy.
