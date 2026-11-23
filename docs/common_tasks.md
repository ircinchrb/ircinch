# Common Tasks

## Checking if a user is online

IRCinch tracks presence from messages it receives. That state can get stale
when the bot stops sharing channels with a user. Call
[`User(nick).monitor`](../lib/cinch/user.rb) to use the server's `MONITOR`
support or poll with `WHOIS` every 30 seconds. Call `unmonitor` to stop.

The `:online` and `:offline` handlers receive `nil` and then the user.
Set up monitoring once per connection, since server subscriptions are
connection-specific. This example guards against repeated `:connect`
events on the same connection.

```ruby
class Presence
  include Cinch::Plugin

  listen_to :connect, method: :on_connect
  listen_to :online, method: :on_online
  listen_to :offline, method: :on_offline

  def on_connect(_message)
    synchronize(:presence_monitor) do
      return if @monitored_connection.equal?(bot.irc)

      User("example_user").monitor
      @monitored_connection = bot.irc
    end
  end

  def on_online(_message, user)
    info "#{user} is online"
  end

  def on_offline(_message, user)
    info "#{user} is offline"
  end
end
```

## Sending messages to users and channels beside `m.user` and `m.channel`

Use the [`User`, `Channel`, and `Target` helpers](../lib/cinch/helpers.rb)
inside a plugin or `on` handler to look up another recipient.

```ruby
User("example_user").send("Hello!")
Channel("#example").send("Hello, channel!")
```

Use `m.reply` to answer the current conversation. If the message came from a
channel, `m.reply(text, true)` prefixes the sender's nickname. A reply to a
`STATUSMSG` uses the same channel audience. Use `safe_reply` or `safe_send`
for text from users or feeds to strip nonprinting characters.

## Formatting messages

Use `Format` with a style or color followed by the text. For example,
`m.reply(Format(:bold, "Ready"))` sends bold text to clients that support IRC
formatting. Use `Unformat(text)` to remove IRC formatting codes or
`Sanitize(text)` to remove nonprintable characters. See the
[formatting options](../lib/cinch/formatting.rb) and [helper methods](../lib/cinch/helpers.rb).

## DCC file transfers

DCC sends the offer over IRC and transfers file data directly between clients.
Open an outgoing file in binary mode and pass it to
[`User(nick).dcc_send(io)`](../lib/cinch/user.rb) from a handler. The call blocks
while waiting for the recipient and transferring the data. The advertised
address can be configured with [`dcc.own_ip`](bot_options.md#dccown_ip).

For incoming offers, listen to [`:dcc_send`](events.md#dcc_send). The offer
exposes `user`, `filename`, `size`, `ip`, and `port`. Calling `accept(output)`
connects to the offered address and writes to an object that supports `<<`.
Review the sender and destination before accepting an offer. Choose the local
output path yourself and enforce your own transfer limits. See the
[incoming transfer API](../lib/cinch/dcc/incoming/send.rb).
