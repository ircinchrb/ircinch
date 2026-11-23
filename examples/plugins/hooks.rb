# frozen_string_literal: true

require_relative "../settings"

class HooksDemo
  include Cinch::Plugin

  hook :pre, method: :generate_random_number
  def generate_random_number(m)
    # Hooks are called in the same thread as the handler and thus
    # using thread local variables is possible.
    Thread.current[:rand] = rand
  end

  hook :post, method: :cheer
  def cheer(m)
    m.reply "Yay, I successfully ran a command…"
  end

  match "rand"
  def execute(m)
    m.reply "Random number: " + Thread.current[:rand].to_s
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_hooks")
    c.plugins.plugins = [HooksDemo]
  end
end

bot.start
