# frozen_string_literal: true

require "ircinch"

module ExampleSettings
  def self.configure(config, nick)
    config.server = ENV.fetch("IRC_SERVER", "localhost")
    config.ssl.use = ENV["IRC_TLS"] == "1"
    config.ssl.verify = config.ssl.use
    config.port = Integer(ENV.fetch("IRC_PORT", config.ssl.use ? "6697" : "6667"), 10)
    config.nick = ENV.fetch("IRC_NICK", nick)
    config.channels = [ENV.fetch("IRC_CHANNEL", "#ircinch-bots")]
  end

  def self.admin?(message)
    admin = ENV["IRC_ADMIN_PREFIX"]
    admin && !admin.empty? && message.user && message.prefix == admin
  end
end
