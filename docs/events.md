# Events

Register handlers with `on` on a bot or `listen_to` in a [plugin](plugins.md).
Each incoming IRC message can dispatch several events. IRCinch provides three kinds:

1. Events mapping directly to IRC commands

   For example `:topic`, which will be triggered when someone changes
   the topic, or `:kick`, when someone gets kicked.

2. Events mapping directly to IRC numeric codes

   For example `:"401"` (`ERR_NOSUCHNICK`) and `:"318"` (`RPL_ENDOFWHOIS`).
   Both `on` and `listen_to` also accept the numeric code as a string or integer.
   See the [numeric constants](../lib/cinch/constants.rb).

3. Events mapping to more abstract ideas

   For example `:leaving` whenever a user parts, quits or gets
   kicked or killed, and `:message` for incoming `PRIVMSG` commands.

## Events of the first two kinds

The first handler argument is the [message object](../lib/cinch/message.rb).
With `on`, any extra arguments passed at registration come next, followed
by regular expression captures. Event-specific arguments follow the captures.

Example:

```ruby
on :topic do |m|
  info "Topic changed in #{m.channel}"
end

on 401 do |m|
  warn "Unknown nickname: #{m.params[1]}"
end
```

## Events of the third kind

These events may add arguments, such as the user who left for `:leaving`.
For `:disconnect`, `:online`, and `:offline`, the first argument is `nil`.

### `:action`

The `:action` event is triggered when a user sends a CTCP ACTION to a
channel or the bot, usually via `/me` in an IRC client. The `on` pattern
matches the action text, available as `m.action_message`.

Example:

```ruby
on :action, "kicks the bot" do |m|
  m.reply "Ouch! Stop kicking me :(", true
end
```

### `:away`

The `:away` event is triggered when a user goes away. This feature
only works on networks implementing the "away-notify" extension.

Example:

```ruby
on :away do |m|
  debug("User %s just went away: %s" % [m.user, m.message])
end
```

See also [the `:unaway` event](#unaway).

### `:ban`

The `:ban` event is triggered when a user gets banned in a channel.

One additional argument, a [Ban object](../lib/cinch/ban.rb), gets passed to
the handler.

Example:

```ruby
on :ban do |m, ban|
  debug("%s just banned %s" % [ban.by, ban.mask])
end
```

See also [the `:unban` event](#unban).

### `:catchall`

`:catchall` is a special event that gets triggered for every incoming
IRC message/command, no matter what the type is.

### `:channel`

The `:channel` event is triggered for `PRIVMSG` and `NOTICE` sent to a
channel, including messages addressed to a subset of users via `STATUSMSG`.

See also [the `:private` event](#private).

### `:connect`

The `:connect` event is dispatched during successful IRC registration,
before channel membership is guaranteed. It can be dispatched more than
once on a connection as the remaining registration numerics arrive. Use
`:join` and check `m.user == bot` for work that requires the bot to be in a
channel.

### `:ctcp`

The `:ctcp` event is triggered for CTCP payloads in `PRIVMSG` or `NOTICE`,
such as a `VERSION` request. Access the command and arguments through
`m.ctcp_command` and `m.ctcp_args`.

### `:dcc_send`

`:dcc_send` gets triggered when a user tries to send a file to the
bot, using the DCC SEND protocol.

The second argument is a [`Cinch::DCC::Incoming::Send`](../lib/cinch/dcc/incoming/send.rb)
offer. See [DCC file transfers](common_tasks.md#dcc-file-transfers).

### `:disconnect`

Fires after the IRC socket closes at the end of the read loop. The message
argument is `nil`. An initial TCP connection failure does not emit this event.

### `:dehalfop`, `:deop`, `:deowner`, `:devoice`

These events get triggered for the respective channel operations of
taking halfop, op, owner and voice from a user.

One additional argument, the user whose rights are being modified, gets
passed to the handler.

### `:error`

`:error` is dispatched for numeric replies in the `400`–`599` range.
`m.error` contains the numeric code as an integer. The IRC `ERROR` command
also dispatches `:error` through its command name.

### `:halfop`

This event gets triggered when a user in a channel gets half-opped.

One additional argument, the user being half-opped, gets passed to the
handler.

### `:leaving`

`:leaving` is an event that is triggered whenever any of the following
are triggered as well: `:part`, `:quit`, `:kick`, `:kill`.

The event can thus be used for noticing when a user leaves a channel
or the network, no matter the reason.

One additional argument, the leaving user, gets passed to the handler.

Be careful not to confuse the additional argument with
[`Cinch::Message#user`](../lib/cinch/message.rb). For example in the case of a kick,
[`Cinch::Message#user`](../lib/cinch/message.rb) will describe the user kicking someone, not the
one who is being kicked.

Example:

```ruby
on :leaving do |m, user|
  if m.channel?
    debug("%s just left %s." % [user, m.channel])
  else
    debug("%s just left the network." % user)
  end
end
```

### `:mode_change`

Fires for channel `MODE` changes. The second argument is an array of
`[direction, mode, parameter]` triples. `direction` is `:add` or `:remove`,
`mode` is a one-letter string, and `parameter` is a string or `nil`.
Use `:mode` to observe raw `MODE` messages, including changes to the bot's
own user modes.

### `:offline`

This event is triggered when a
[monitored user](common_tasks.md#checking-if-a-user-is-online)
goes offline.

The handler receives `nil` followed by the monitored user.

### `:online`

This event is triggered when a
[monitored user](common_tasks.md#checking-if-a-user-is-online)
comes online.

The handler receives `nil` followed by the monitored user.

### `:op`

This event gets triggered when a user in a channel gets opped.

One additional argument, the user being opped, gets passed to the
handler.

### `:owner`

This event gets triggered when a user in a channel receives
owner-status.

One additional argument, the user receiving owner-status, gets passed
to the handler.

### `:message`

The `:message` and `:privmsg` events both fire for an incoming `PRIVMSG` to
a channel or directly to the bot, including CTCP requests carried in `PRIVMSG`.

### `:private`

The `:private` event is triggered for `PRIVMSG` and `NOTICE` directed to
the bot outside a channel.

See also [the `:channel` event](#channel).

### `:unaway`

The `:unaway` event is triggered when a user no longer is away. This
feature only works on networks implementing the "away-notify"
extension.

Example:

```ruby
on :unaway do |m|
  debug("User %s no longer is away." % m.user)
end
```

See also [the `:away` event](#away).

### `:unban`

The `:unban` event is triggered when a user gets unbanned in a
channel.

One additional argument, a [Ban object](../lib/cinch/ban.rb), gets passed to the
handler.

### `:voice`

This event gets triggered when a user in a channel gets voiced.

One additional argument, the user being voiced, gets passed to the
handler.

## Custom events

Call `bot.handlers.dispatch(:event_name, message, *args)` to notify handlers
registered for your own event. Pass `nil` when there is no originating IRC
message and use a [listener](plugins.md#listening-to-events) to receive it.
The public dispatcher returns the threads started for the handlers.
