# Bot Options

Set options inside `bot.configure { |c| ... }`. Options below show the
defaults for this checkout. See the [configuration source](../lib/cinch/configuration/bot.rb)
and the [getting-started guide](getting_started.md) for a complete bot example.

## `channels`

- **Type** `Array<String>`
- **Default** `[]`

The bot joins these channels after registration, subject to [`delay_joins`](#delay_joins).

**Notes**

- To join a keyed channel from a handler, call `bot.join(channel_name, key)`.
  Keep channel keys outside the source file.

## `dcc`

### `dcc.own_ip`

- **Type** `String`
- **Default** `nil`

The IP address advertised for outgoing DCC transfers. With `nil`, IRCinch
uses the local address of the IRC socket. The recipient needs to be able to
reach the advertised address and listening port. See [DCC file transfers](common_tasks.md#dcc-file-transfers).

## `default_logger_level`

- **Type** `Symbol`
- **Default** `:debug`

The initial level used when the bot constructs its default logger. That logger
is created before the bot's configuration block runs. Set `bot.loggers.first.level`
to change it on an existing bot. See [logger levels](logging.md#logger-levels).

## `delay_joins`

- **Type** `Numeric`, `Symbol`
- **Default** `0`

With a number, wait that many seconds after IRC registration before joining
configured channels. With a symbol, join when that event first fires on the
connection.

## `encoding`

- **Type** `String`, `Encoding`, or `:irc`
- **Default** `:irc`

Controls decoding of incoming text and encoding of outgoing text. See [Encodings](encodings.md).

## `local_host`

- **Type** `String`
- **Default** `nil`

The local address or hostname to bind when opening the IRC connection.

## `max_messages`

- **Type** `Integer`
- **Default** `nil`

Maximum number of parts sent per input line. `nil` sends all parts.

## `max_reconnect_delay`

- **Type** `Integer`
- **Default** `300`

Maximum reconnect delay in seconds. After an unsuccessful connection attempt,
IRCinch doubles the wait up to this cap. A successful registration resets the
backoff.

## `messages_per_second`

- **Type** Positive `Numeric`
- **Default** `nil`

Estimated rate at which the server processes messages sent by the bot. `nil`
uses the [network default](../lib/cinch/network.rb). This estimate controls
outgoing throttling together with [`server_queue_size`](#server_queue_size).

**Notes**

- If your bot gets kicked for excess flood, try lowering the value of
  `messages_per_second`.
- See also: [`server_queue_size`](#server_queue_size)

## `message_split_end`

- **Type** `String`
- **Default** `" ..."`

When a message is too long to be sent as a whole, it will be split
and the value of this option will be appended to all but the last
part. Use `nil` or `""` to omit the marker.

## `message_split_start`

- **Type** `String`
- **Default** `"... "`

When a message is too long to be sent as a whole, it will be split
and the value of this option will be prepended to all but the first
part. Use `nil` or `""` to omit the marker.

## `modes`

- **Type** `Array<String>`
- **Default** `[]`

User mode letters to set on the bot after registration, such as `["i"]`.
Set this with `c.modes = [...]` in a configuration block. The current
configuration class does not accept `:modes` through `[]` or `load`.

## `nick`

- **Type** `String`
- **Default** `"ircinch"`

The nickname the bot will use.

**Notes**

- If the nickname is in use, IRCinch will append underscores until it
  finds a free nick.
- You really should set this option instead of using the default.

## `nicks`

- **Type** `Array<String>`
- **Default** `nil`

A nonempty list of preferred nicknames, tried in order before appending
underscores. With `nil`, the bot starts with [`nick`](#nick).

## `password`

- **Type** `String`
- **Default** `nil`

Password sent with the IRC `PASS` command. For account authentication on a
server that supports SASL, see [`sasl`](#sasl).

## `ping_interval`

- **Type** `Numeric`
- **Default** `120`

Interval in seconds between client `PING` commands.

**Notes**

- The ping interval should be smaller than
  [`timeouts.read`](#timeoutsread) to prevent IRCinch from
  falsely declaring a connection dead.

## `plugins`

### `plugins.plugins`

- **Type** `Array<Class>`
- **Default** `[]`

A list of plugins to register.

**Notes**

- An example: `[Plugin1, Plugin2, Plugin3]` -- Note that we are adding
  the plugin **classes** to the list.

### `plugins.prefix`

- **Type** `String`, `Regexp`, `Proc`, or `nil`
- **Default** `/^!/`

Default prefix for plugin matchers. See [matching messages](plugins.md#matching-messages)
for overrides and how strings and regular expressions are combined.

### `plugins.suffix`

- **Type** `String`, `Regexp`, `Proc`, or `nil`
- **Default** `nil`

Default suffix for plugin matchers.

### `plugins.options`

- **Type** `Hash`
- **Default** `Hash.new {|h,k| h[k] = {}}`

Options keyed by plugin class, with an empty hash for each class by default.
See [plugin configuration](plugins.md#configuration).

## `port`

- **Type** `Integer`
- **Default** `6667`

The port the IRC server is listening on. Set the server's TLS port when
enabling [`ssl.use`](#ssluse).

## `realname`

- **Type** `String`
- **Default** `"ircinch"`

The real name Cinch will connect with.

## `reconnect`

- **Type** `Boolean`
- **Default** `true`

Retry after connection failures or disconnects. Calling `bot.quit` disables
reconnection for that run.

## `sasl`

Set the username and password for an IRC account on a server that advertises
SASL. Use TLS for `PLAIN`, which encodes the password without encrypting it.
See [`ssl`](#ssl) for IRCinch's TLS settings and verification behavior.

### `sasl.username`

- **Type** `String`
- **Default** `nil`

The username to use for SASL authentication.

### `sasl.password`

- **Type** `String`
- **Default** `nil`

The password to use for SASL authentication.

### `sasl.mechanisms`

- **Type** `Array<Cinch::SASL::Mechanism>`
- **Default** `[Cinch::SASL::DhBlowfish, Cinch::SASL::Plain]`

Mechanisms to try in order. The bot tries the next one when the server sends
numeric `904` (authentication failed). For a network using `PLAIN`, set this
to `[Cinch::SASL::Plain]`.

## `server`

- **Type** `String`
- **Default** `"localhost"`

The IRC server to connect to.

## `server_queue_size`

- **Type** Positive `Integer`
- **Default** `nil`

Estimated number of pending commands the server can queue for this connection.
`nil` uses the [network default](../lib/cinch/network.rb).

**Notes**

- If your bot gets kicked for excess flood, try lowering the value of
  `server_queue_size`.
- See also: [`messages_per_second`](#messages_per_second)

## `ssl`

### `ssl.use`

- **Type** `Boolean`
- **Default** `false`

Open the connection with TLS. Choose the network's TLS [`port`](#port) explicitly.

### `ssl.verify`

- **Type** `Boolean`
- **Default** `false`

Enable verification of the server certificate chain. The current TLS
implementation does not check whether the certificate matches the server
hostname. See the [connection source](../lib/cinch/irc.rb) and
[Ruby OpenSSL documentation](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html#attribute-i-verify_hostname).

### `ssl.ca_path`

- **Type** `String`
- **Default** `"/etc/ssl/certs"`

The path to a directory with certificates. This has to be set
  properly for [`ssl.verify`](#sslverify) to work.

### `ssl.client_cert`

- **Type** `String`
- **Default** `nil`

Path to a PEM file containing both the client certificate and its RSA private
key. Some networks use it for account authentication. See [OFTC’s CertFP guide](https://www.oftc.net/NickServ/CertFP/).

## `shared`

- **Type** `Hash`
- **Default** `{}`

Per-bot data accessible to plugin instances through `shared`. Use
`synchronize` for updates that can run in concurrent handlers.

## `strictness`

- **Type** `:forgiving` or `:strict`
- **Default** `:forgiving`

In strict mode, changing the bot's nickname or a channel topic, or kicking
a user, raises an exception when the supplied value exceeds the server's
advertised limit. In forgiving mode the request goes to the server.

## `timeouts`

### `timeouts.read`

- **Type** `Numeric`
- **Default** `240`

Socket read timeout in seconds. An expired read closes the connection.

### `timeouts.connect`

- **Type** `Numeric`
- **Default** `10`

Timeout in seconds for opening the TCP socket. The TLS handshake follows
afterward.

## `user`

- **Type** `String`
- **Default** `"ircinch"`

The username sent with the IRC `USER` command. Set [`sasl.username`](#saslusername)
separately for SASL authentication.
