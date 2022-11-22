require "cinch"

class HooksDemo
  include Cinch::Plugin

  hook :pre, method: :generate_random_number
  def generate_random_number(m)
    # Hooks are called in the same thread as the handler and thus
    # using thread local variables is possible.
    Thread.current[:rand] = Kernel.rand
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
    c.nick = "ircinch_hooks"
    c.server = "irc.libera.chat"
    c.channels = ["#ircinch-bots"]
    c.verbose = true
    c.plugins.plugins = [HooksDemo]
  end
end

bot.start
