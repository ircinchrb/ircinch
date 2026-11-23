# Historical Cinch Changelog

These release notes describe the original Cinch 1.1–2.2 releases. See the
[IRCinch Changelog](../CHANGELOG.md) for later releases and the
[documentation index](readme.md) for current usage.

## What has changed in 2.2?

### Getting rid of CP1252 in favour of UTF-8

In versions before 2.2, when using the `irc` encoding (the default),
Cinch would use CP1252 for outgoing messages, only falling back to
UTF-8 if a message wouldn't fit into CP1252. This is a so called
hybrid encoding, which is used by X-Chat and the like.

This encoding, however, is based on the state of 10 years ago, where
the most popular IRC clients, such as mIRC, weren't capable of
handling UTF-8. Nowadays, there are more clients that support UTF-8
than there are clients that can deal with this hybrid encoding, or
CP1252 itself. That's why, from now on, we will always use UTF-8.

If you depend on outgoing messages being encoded in CP1252, please see
[Encodings](encodings.md) on how to change the encoding.

### API improvements

#### New methods

- [`Cinch::Channel#remove`](../lib/cinch/channel.rb) has been added to support the non-standard
REMOVE command, a friendlier alternative to kicking people.

- [`Cinch::Helpers.sanitize`](../lib/cinch/helpers.rb) and [`Cinch::Formatting.unformat`](../lib/cinch/formatting.rb) have been
  added to help with removing unprintable characters and mIRC
  formatting codes from strings.

#### Deprecated methods

In order to reduce the amount of aliases, the following ones have been
deprecated and will be removed in a future release:

- [`Cinch::Channel#msg`](../lib/cinch/channel.rb)
- [`Cinch::Channel#privmsg`](../lib/cinch/channel.rb)
- [`Cinch::Target#msg`](../lib/cinch/target.rb)
- [`Cinch::Target#privmsg`](../lib/cinch/target.rb)
- [`Cinch::Target#safe_msg`](../lib/cinch/target.rb)
- [`Cinch::Target#safe_privmsg`](../lib/cinch/target.rb)
- [`Cinch::User#whois`](../lib/cinch/user.rb)
- [`Cinch::Helpers#Color`](../lib/cinch/helpers.rb)

Additionally, the following method is deprecated and will be removed
in the future:

- [`Cinch::Channel#to_str`](../lib/cinch/channel.rb)

## What has changed in 2.1?

1. Color stripping
1. Per group hooks
1. API improvements
   1. New methods
   1. Changed methods
   1. New aliases

### Color stripping

[`Cinch::Formatting.unformat`](../lib/cinch/formatting.rb) removes mIRC color
codes from messages. It replaces `Cinch::Utilities::String.strip_colors`.

Additionally, a new match option called `strip_colors` makes it
possible to automatically and temporarily strip color codes before
attempting to match a message.

### Per group hooks

A new option `group` for hooks allows registering hooks for specific
groups.

### API improvements

#### New methods

##### [`Cinch::Bot`](../lib/cinch/bot.rb)

- [`Cinch::Bot#oper`](../lib/cinch/bot.rb)

##### [`Cinch::User`](../lib/cinch/user.rb)

- [`Cinch::User#oper?`](../lib/cinch/user.rb)

##### [`Cinch::Message`](../lib/cinch/message.rb)

- [`Cinch::Message#action_reply`](../lib/cinch/message.rb)
- [`Cinch::Message#safe_action_reply`](../lib/cinch/message.rb)

#### Changed methods

##### [`Cinch::Handler`](../lib/cinch/handler.rb)

- [`Cinch::Handler#call`](../lib/cinch/handler.rb) now returns the started thread.

##### [`Cinch::HandlerList`](../lib/cinch/handler_list.rb)

- [`Cinch::HandlerList#dispatch`](../lib/cinch/handler_list.rb) now returns the started threads.

#### New aliases

Due to some unfortunate naming mistakes in Cinch 2.0, Cinch 2.1 adds
several aliases. All of the new aliases deprecate the original method
names, which will be removed in Cinch 3.0.

##### [`Cinch::User`](../lib/cinch/user.rb)

- [`Cinch::User#monitored?`](../lib/cinch/user.rb) for [`Cinch::User#monitored`](../lib/cinch/user.rb)
- [`Cinch::User#synced?`](../lib/cinch/user.rb) for [`Cinch::User#synced`](../lib/cinch/user.rb)

## What has changed in 2.0?

1. Added support for SASL
1. Added support for DCC SEND
1. Added a fair scheduler for outgoing messages
1. Added required plugin options
1. Added support for colors/formatting
1. Added network discovery
1. Added match groups
1. Added match options overwriting plugin options
1. Added support for actions (/me)
1. Added support for broken IRC networks
1. Dynamic timers
1. Reworked logging facilities
1. API improvements
   1. Helper changes
   1. Added a `Cinch::Target` class
   1. Cinch::Constants
   1. New methods
   1. Removed/Renamed methods
   1. Handlers
   1. The Plugin class
   1. Channel/Target/User implement Comparable
   1. Renamed `*Manager` to `*List`
1. New events

### Added support for SASL

Cinch now supports authenticating to services via SASL. For more
information check [`Cinch::SASL`](../lib/cinch/sasl.rb).

### Added support for DCC SEND

Support for sending and receiving files via DCC has been added to
Cinch. Check [`Cinch::DCC`](../lib/cinch/dcc.rb) for more information.

### Added a fair scheduler for outgoing messages

Cinch always provided sophisticated throttling to avoid getting kicked
due to _excess flood_. One major flaw, however, was that it used a
single FIFO for all messages, thus preferring early message targets
and penalizing later ones.

Now Cinch uses a round-robin approach, having one queue per message
target (channels and users) and one for generic commands.

### Added required plugin options

Plugins can now require specific options to be set. If any of those
options are not set, the plugin will automatically refuse being
loaded.

This is useful for example for plugins that require API keys to
interact with web services.

The new attribute is called
[`required_options`](../lib/cinch/plugin.rb).

Example:

```ruby
class MyPlugin
  include Cinch::Plugin

  set :required_options, [:foo, :bar]
  # ...
end

# ...

bot.configure do |c|
  c.plugins.plugins = [MyPlugin]
  c.plugins.options[MyPlugin] = {:foo => 1}
end

# The plugin won't load because the option :bar is not set.
# Instead it will print a warning.
```

### Added support for colors/formatting

A new [module](../lib/cinch/formatting.rb) and [`helper`](../lib/cinch/helpers.rb)
for adding colors and formatting to messages has been added. See the
[module's documentation](../lib/cinch/formatting.rb) for more information on
usage.

### Added support for network discovery

Cinch now tries to detect the network it connects to, including the
running IRCd. For most parts this is only interesting internally, but
if you're writing advanced plugins that hook directly into IRC and
needs to be aware of available features/quirks, check out
[`Cinch::IRC#network`](../lib/cinch/irc.rb) and [`Cinch::Network`](../lib/cinch/network.rb).

### Reworked logging facilities

The logging API has been drastically improved. Check the
[logging documentation](logging.md) for more information.

### Added match groups

A new option for matchers, `:group`, allows grouping multiple matchers
to a group. What's special is that in any group, only the first
matching handler will be executed.

Example:

```ruby
class Foo
  include Cinch::Plugin

  match /foo (\d+)/, group: :blegh, method: :foo1
  match /foo (.+)/,  group: :blegh, method: :foo2
  match /foo .+/,                   method: :foo3
  def foo1(m, arg)
    m.reply "foo1"
  end

  def foo2(m, arg)
    m.reply "foo2"
  end

  def foo3(m)
    m.reply "foo3"
  end
end
# 02:05:39       dominikh │ !foo 123
# 02:05:40          cinch │ foo1
# 02:05:40          cinch │ foo3

# 02:05:43       dominikh │ !foo bar
# 02:05:44          cinch │ foo2
# 02:05:44          cinch │ foo3
```

### Added match options overwriting plugin options

Matchers now have their own `:prefix`, `:suffix` and `:react_on`
options which overwrite plugin options for single matchers.

### Added support for actions (/me)

A new event, {`:action`} has been added and can be used for matching
actions as follows:

```ruby
match "kicks the bot", react_on: :action
def execute(m)
  m.reply "Ouch!"
end
```

### API improvements

#### Helper changes

The helper methods [`User()`](../lib/cinch/helpers.rb) and
[`Channel()`](../lib/cinch/helpers.rb) have been extracted from
[`Cinch::Bot`](../lib/cinch/bot.rb) and moved to [their own module](../lib/cinch/helpers.rb) which can
be reused in various places.

#### Added a [Target](../lib/cinch/target.rb) class

Since [`Cinch::Channel`](../lib/cinch/channel.rb) and [`Cinch::User`](../lib/cinch/user.rb) share one common interface
for sending messages, it only makes sense to have a common base class.
[This new class](../lib/cinch/target.rb) takes care of sending messages and
removes this responsibility from [`Cinch::Channel`](../lib/cinch/channel.rb), [`Cinch::User`](../lib/cinch/user.rb) and
[`Cinch::Bot`](../lib/cinch/bot.rb)

#### [`Cinch::Constants`](../lib/cinch/constants.rb)

All constants for IRC numeric replies (`RPL_*` and `ERR_*`) have been
moved from [`Cinch`](../lib/cinch/ban.rb) to [`Cinch::Constants`](../lib/cinch/constants.rb)

#### New methods

##### [`Cinch::Bot`](../lib/cinch/bot.rb)

- [`Cinch::Bot#channel_list`](../lib/cinch/bot.rb)
- [`Cinch::Bot#handlers`](../lib/cinch/bot.rb)
- [`Cinch::Bot#loggers`](../lib/cinch/bot.rb)
- [`Cinch::Bot#loggers=`](../lib/cinch/bot.rb)
- [`Cinch::Bot#modes`](../lib/cinch/bot.rb)
- [`Cinch::Bot#modes=`](../lib/cinch/bot.rb)
- [`Cinch::Bot#set_mode`](../lib/cinch/bot.rb)
- [`Cinch::Bot#unset_mode`](../lib/cinch/bot.rb)
- [`Cinch::Bot#user_list`](../lib/cinch/bot.rb)

##### [`Cinch::Channel`](../lib/cinch/channel.rb)

- [`Cinch::Channel#admins`](../lib/cinch/channel.rb)
- [`Cinch::Channel#half_ops`](../lib/cinch/channel.rb)
- [`Cinch::Channel#ops`](../lib/cinch/channel.rb)
- [`Cinch::Channel#owners`](../lib/cinch/channel.rb)
- [`Cinch::Channel#voiced`](../lib/cinch/channel.rb)

##### [`Cinch::Helpers`](../lib/cinch/helpers.rb)

- [`Cinch::Helpers#Target`](../lib/cinch/helpers.rb) -- For creating a [Target](../lib/cinch/target.rb) which can receive messages
- [`Cinch::Helpers#Timer`](../lib/cinch/helpers.rb)  -- For creating new timers anywhere
- [`Cinch::Helpers#rescue_exception`](../lib/cinch/helpers.rb) -- For rescueing and automatically logging an exception
- [`Cinch::Helpers#Format`](../lib/cinch/helpers.rb) -- For adding colors and formatting to messages

###### Logging shortcuts

- [`Cinch::Helpers#debug`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#error`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#exception`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#fatal`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#incoming`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#info`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#log`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#outgoing`](../lib/cinch/helpers.rb)
- [`Cinch::Helpers#warn`](../lib/cinch/helpers.rb)

##### [`Cinch::IRC`](../lib/cinch/irc.rb)

- [`Cinch::IRC#network`](../lib/cinch/irc.rb)

##### [`Cinch::Message`](../lib/cinch/message.rb)

- [`Cinch::Message#action?`](../lib/cinch/message.rb)
- [`Cinch::Message#action_message`](../lib/cinch/message.rb)
- [`Cinch::Message#target`](../lib/cinch/message.rb)
- [`Cinch::Message#time`](../lib/cinch/message.rb)

##### [`Cinch::Plugin`](../lib/cinch/plugin.rb)

- [`Cinch::Plugin#handlers`](../lib/cinch/plugin.rb)
- [`Cinch::Plugin#timers`](../lib/cinch/plugin.rb)
- [`Cinch::Plugin#unregister`](../lib/cinch/plugin.rb)

##### [`Cinch::User`](../lib/cinch/user.rb)

- [`Cinch::User#away`](../lib/cinch/user.rb)
- [`Cinch::User#dcc_send`](../lib/cinch/user.rb) - See [`Cinch::DCC::Outgoing::Send`](../lib/cinch/dcc/outgoing/send.rb)
- [`Cinch::User#match`](../lib/cinch/user.rb)
- [`Cinch::User#monitor`](../lib/cinch/user.rb) - See [Checking if a user is online](common_tasks.md#checking-if-a-user-is-online)
- [`Cinch::User#monitored`](../lib/cinch/user.rb)
- [`Cinch::User#online?`](../lib/cinch/user.rb)
- [`Cinch::User#unmonitor`](../lib/cinch/user.rb)

#### Handlers

Internally, Cinch uses [Handlers](../lib/cinch/handler.rb) for listening to and
matching events. In previous versions, this was hidden from the user,
but now they're part of the public API, providing valuable information
and the chance to [unregister handlers](../lib/cinch/handler.rb)
alltogether.

[`Cinch::Bot#on`](../lib/cinch/bot.rb) now returns the created handler and
[`Cinch::Plugin#handlers`](../lib/cinch/plugin.rb) allows getting a plugin's registered
handlers.

#### Removed/Renamed methods

The following methods have been removed:

- `Cinch::Bot#halt` → `next` or `break` (Ruby keywords)
- `Cinch::Bot#raw` → [`Cinch::IRC#send`](../lib/cinch/irc.rb)
- `Cinch::Bot#msg` → [`Cinch::Target#msg`](../lib/cinch/target.rb)
- `Cinch::Bot#notice` → [`Cinch::Target#notice`](../lib/cinch/target.rb)
- `Cinch::Bot#safe_msg` → [`Cinch::Target#safe_msg`](../lib/cinch/target.rb)
- `Cinch::Bot#safe_notice` → [`Cinch::Target#safe_notice`](../lib/cinch/target.rb)
- `Cinch::Bot#action` → [`Cinch::Target#action`](../lib/cinch/target.rb)
- `Cinch::Bot#safe_action` → [`Cinch::Target#safe_action`](../lib/cinch/target.rb)
- `Cinch::Bot#dispatch` → [`Cinch::HandlerList#dispatch`](../lib/cinch/handler_list.rb)
- `Cinch::Bot#register_plugins` → [`Cinch::PluginList#register_plugins`](../lib/cinch/plugin_list.rb)
- `Cinch::Bot#register_plugin` → [`Cinch::PluginList#register_plugin`](../lib/cinch/plugin_list.rb)
- `Cinch::Bot#logger` → [`Cinch::Bot#loggers`](../lib/cinch/bot.rb)
- `Cinch::Bot#logger=` was removed.
- `Cinch::Bot#debug` → [`Cinch::LoggerList#debug`](../lib/cinch/logger_list.rb)
- `Cinch::IRC#message` → [`Cinch::IRC#send`](../lib/cinch/irc.rb)
- `Cinch::Logger::Logger#log_exception` → [`Cinch::Logger#exception`](../lib/cinch/logger.rb)
- Class methods in Plugin to set options → A new [`set`](../lib/cinch/plugin.rb) method as well as attribute setters

#### The Plugin class

The [Plugin](../lib/cinch/plugin.rb) class has been drastically improved to look
and behave more like a proper Ruby class instead of being some
abstract black box.

All attributes of a plugin (name, help message, matchers, …) are being
made available via attribute getters and setters. Furthermore, it is
possible to access a Plugin instance's registered handlers and timers,
as well as unregister plugins.

For a complete overview of available attributes and methods, see
[`Cinch::Plugin`](../lib/cinch/plugin.rb) and [`Cinch::Plugin::ClassMethods`](../lib/cinch/plugin.rb).

#### Plugin options

The aforementioned changes also affect the way plugin options are
being set: Plugin options aren't set with DSL-like methods anymore but
instead are made available via [a `set` method](../lib/cinch/plugin.rb) or alternatively plain attribute setters.

See
[the migration guide](migrating.md#plugin-options) for more
information.

#### Channel/Target/User implement Comparable

[`Cinch::Target`](../lib/cinch/target.rb) and thus [`Cinch::Channel`](../lib/cinch/channel.rb) and [`Cinch::User`](../lib/cinch/user.rb) now
implement the Comparable interface, which makes them sortable by all
usual Ruby means.

#### Renamed `*Manager` to `*List`

`Cinch::ChannelManager` and `Cinch::UserManager` have been renamed to
[`Cinch::ChannelList`](../lib/cinch/channel_list.rb) and [`Cinch::UserList`](../lib/cinch/user_list.rb) respectively.

### Added support for broken IRC networks

Special support for the following flawed IRC networks has been added:

- JustinTV
- NGameTV
- IRCnet

### Dynamic timers

It is now possible to create new timers from any method/handler. It is
also possible to [stop existing timers](../lib/cinch/timer.rb) or
[restart them](../lib/cinch/timer.rb).

The easiest way of creating new timers is by using the
[Timer helper method](../lib/cinch/helpers.rb), even though it is also
possible, albeit more complex, to create instances of [`Cinch::Timer`](../lib/cinch/timer.rb)
directly.

Example:

```ruby
match /remind me in (\d+) seconds/
def execute(m, seconds)
  Timer(seconds.to_i, shots: 1) do
    m.reply "This is your reminder.", true
  end
end
```

For more information on timers, see the [Timer documentation](../lib/cinch/timer.rb).

### New options

- [:dcc.own_ip](bot_options.md#dccown_ip)
- [:modes](bot_options.md#modes)
- [:max_reconnect_delay](bot_options.md#max_reconnect_delay)
- [:local_host](bot_options.md#local_host)
- [:delay_joins](bot_options.md#delay_joins)
- [:sasl.username](bot_options.md#saslusername)
- [:sasl.password](bot_options.md#saslpassword)

### New events

- [`:action`](events.md#action)
- [`:away`](events.md#away)
- [`:unaway`](events.md#unaway)
- [`:dcc_send`](events.md#dcc_send)
- [`:owner`](events.md#owner)
- [`:deowner`](events.md#dehalfop-deop-deowner-devoice)
- [`:leaving`](events.md#leaving)
- [`:online`](events.md#online)
- [`:offline`](events.md#offline)

## What has changed in 1.1?

1. **New events**
2. **New methods**
3. **New options**
4. **Improved logger**
5. **Deprecated methods**

### New events

- [`:op`](events.md#op)
- [`:deop`](events.md#dehalfop-deop-deowner-devoice)
- [`:voice`](events.md#voice)
- [`:devoice`](events.md#dehalfop-deop-deowner-devoice)
- [`:halfop`](events.md#halfop)
- [`:dehalfop`](events.md#dehalfop-deop-deowner-devoice)
- [`:ban`](events.md#ban)
- [`:unban`](events.md#unban)
- [`:mode_change`](events.md#mode_change)
- [`:catchall`](events.md#catchall)

Additionally, plugins are now able to send their own events by using
Cinch::Bot#dispatch.

### New methods

#### [`Cinch::User#last_nick`](../lib/cinch/user.rb)

Stores the last nick of a user. This can for example be used in `on
:nick` to compare a user's old nick against the new one.

#### Cinch::User#notice, Cinch::Channel#notice and Cinch::Bot#notice

For sending notices.

#### [`Cinch::Message#to_s`](../lib/cinch/message.rb)

Provides a nicer representation of [`Cinch::Message`](../lib/cinch/message.rb) objects.

#### [`Cinch::Channel#has_user?`](../lib/cinch/channel.rb)

Provides an easier way of checking if a given user is in a channel

### New options

- [`plugins.suffix`](bot_options.md#pluginssuffix)
- [`ssl.use`](bot_options.md#ssluse)
- [`ssl.verify`](bot_options.md#sslverify)
- [`ssl.ca_path`](bot_options.md#sslca_path)
- [`ssl.client_cert`](bot_options.md#sslclient_cert)
- [`nicks`](bot_options.md#nicks)
- [`timeouts.read`](bot_options.md#timeoutsread)
- [`timeouts.connect`](bot_options.md#timeoutsconnect)
- [`ping_interval`](bot_options.md#ping_interval)
- [`reconnect`](bot_options.md#reconnect)

### Improved logger

The [formatted logger](../lib/cinch/logger/formatted_logger.rb) (which is the
default one) now contains timestamps. Furthermore, it won't emit color
codes if not writing to a TTY.

Additionally, it can now log any kind of object, not only strings.

### Deprecated methods

- `Cinch::User.find_ensured` → `Cinch::UserManager#find_ensured`
- `Cinch::User.find` → `Cinch::UserManager#find`
- `Cinch::User.all` → `Cinch::UserManager#each`
- `Cinch::Channel.find_ensured` → `Cinch::ChannelManager#find_ensured`
- `Cinch::Channel.find` → `Cinch::ChannelManager#find`
- `Cinch::Channel.all` → `Cinch::ChannelManager#each`
