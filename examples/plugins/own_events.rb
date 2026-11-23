# frozen_string_literal: true

require_relative "../settings"

class RandomNumberGenerator
  include Cinch::Plugin

  timer 5, method: :publish

  def publish
    bot.handlers.dispatch(:random_number, nil, rand)
  end
end

class RandomNumberReporter
  include Cinch::Plugin

  listen_to :random_number

  def listen(_message, number)
    bot.channels.first&.send("I got a random number: #{number}")
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_event")
    c.plugins.plugins = [RandomNumberGenerator, RandomNumberReporter]
  end
end

bot.start
