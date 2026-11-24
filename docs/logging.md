# Logging

## Using the logger

Use `debug`, `info`, `warn`, `error`, and `fatal` in plugins and `on` handlers.
The helpers send messages to [`bot.loggers`](../lib/cinch/logger_list.rb).

```ruby
on :join do |m|
  info "#{m.user} joined #{m.channel}"
end
```

## Logger levels

From most verbose to least verbose, the levels are `:debug`, `:log`,
`:info`, `:warn`, `:error`, and `:fatal`. A logger emits messages at or above
its configured level. `:debug` is the initial level. `:log` still includes
raw incoming and outgoing IRC traffic. Use `:info` or higher to omit that
traffic from normal logging.

### Changing the level

The bot starts with one formatted logger on standard error. Assign `level`
on a logger to change its threshold. Assign `bot.loggers.level` to change
all loggers already in the list. Set the level of each logger when you add it.

```ruby
bot.loggers.first.level = :info
file = File.open("ircinch.log", "a")
bot.loggers << Cinch::Logger::FormattedLogger.new(file, level: :warn)
```

Keep the file open while the bot is using it and close it after the bot stops.
The [formatted logger](../lib/cinch/logger/formatted_logger.rb) adds timestamps
and uses color on a terminal. For incoming IRC lines in pisg's Zcbot format,
load `require "cinch/logger/zcbot_logger"` and add a
[`Cinch::Logger::ZcbotLogger`](../lib/cinch/logger/zcbot_logger.rb) to the list.

## Redacting outgoing messages

Pass `sensitive: true` to `Target#send` or `IRC#send` to log `[REDACTED]`
in place of the outgoing line. The flag applies to successful sends,
failed-write log messages, and each line of a split target message.
The server receives the original IRC command.

```ruby
User("NickServ").send("IDENTIFY #{password}", sensitive: true)
```

IRCinch applies the flag to server passwords, SASL responses, oper passwords,
and channel keys sent by the built-in helpers.

## Log filtering

Add an object with a `filter(message, event)` method to `bot.loggers.filters`.
Return the message to keep it, a replacement string to modify it, or `nil`
to drop it. Filters run in order. Calls to `bot.loggers.exception` bypass them.

## Writing your own logger

Subclass [`Cinch::Logger`](../lib/cinch/logger.rb) and override private
formatters such as `format_general(message)` for all messages or
`format_info(message)` for a particular event. The base class applies the
level threshold, serializes writes, and sends the result to the supplied
output object. An event-specific formatter can return `nil` to skip a message.

```ruby
class ServiceLogger < Cinch::Logger
  private

  def format_info(message)
    "[service] #{message}"
  end
end

bot.loggers << ServiceLogger.new($stderr, level: :info)
```
