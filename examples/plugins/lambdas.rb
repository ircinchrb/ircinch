# frozen_string_literal: true

require_relative "../settings"

class DirectAddressing
  include Cinch::Plugin

  # Note: the lambda will be executed in the context it has been
  # defined in, in this case the class DirectAddressing (and not an
  # instance of said class).
  #
  # The reason we are using a lambda is that the bot's nick can change
  # and the prefix has to be up to date.
  set :prefix, lambda { |m| Regexp.new("^" + Regexp.escape(m.bot.nick + ": ")) }

  match "hello", method: :greet
  def greet(m)
    m.reply "Hello to you, too."
  end

  match "rename", method: :rename
  def rename(m)
    bot.nick += "_" if ExampleSettings.admin?(m)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_addr")
    c.plugins.plugins = [DirectAddressing]
  end
end

bot.start
