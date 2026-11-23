# frozen_string_literal: true

require_relative "../settings"

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_msg")
  end

  on :message, /\A!msg ([^\s,#&]+) (.+)\z/ do |m, who, text|
    User(who).safe_send(text) if ExampleSettings.admin?(m)
  end
end

bot.start
