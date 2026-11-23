# frozen_string_literal: true

require_relative "../settings"

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_hello")
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
  end
end

bot.start
