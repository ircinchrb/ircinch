# Getting Started

This guide builds an IRC bot with IRCinch. Install it with `gem install ircinch`
or `bundle add ircinch` in an existing Bundler project. The gem loads with
`require "ircinch"` and exposes the Ruby API under `Cinch`.

Choose an IRC server, a unique nickname, and a channel where you can test.
The examples use the default plain-text port, `6667`, without credentials.
See the [Libera.Chat connection guide](https://libera.chat/guides/connect)
and the [bot's TLS and account settings](bot_options.md#ssl) for other setups.

## What IRCinch really is

First and foremost, it is important to understand that IRCinch is more
of an API for IRC access than a full-blown bot framework like Autumn
or Rbot.

There will be no enforced directory structures, no magical places from
which plugins will be loaded and no obscure, "fancy" names. Plugins
will be plugins and not "leaves".

This, however, does not mean that IRCinch requires you to be familiar
with the internals of the IRC protocol. Quite the opposite: A very
high-level abstraction is provided, allowing things such as

```ruby
Channel("#ircinch").users.each do |user, modes|
  user.send "I am watching you!"
end
```

to work.

Furthermore, the API has been designed in a way that it sticks true to
the way Ruby looks and behaves. Plugins are normal classes that mix-in
a module, functions of the bot are implemented as normal methods and
so on.

## Hello, World

The following will describe one of the most basic IRC bots you can
write in IRCinch: One that joins a specific channel and responds to
"hello" by saying "Hello, World".

```ruby
require "ircinch"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "my_example_bot"
    c.channels = ["#ircinch-bots"]
  end

  on :message, "hello" do |m|
    m.reply "Hello, World"
  end
end

bot.start
```

Save the example as `bot.rb`, replace the nickname and channel as needed,
and run `ruby bot.rb` (or `bundle exec ruby bot.rb` with Bundler). After the
bot joins, send `hello` from another IRC client in that channel. The bot
starts its connection loop at `bot.start`. Use Ctrl-C to stop the process.

### In Detail

First, we create a bot. The [`configure`](../lib/cinch/bot.rb) method yields
the configuration object. In this example, we set which server to connect
to and which channel to join.
Another often-used option is the nickname of the bot
([`c.nick`](bot_options.md#nick)). For an overview of all
available options, see [the list of options](bot_options.md).

Following, we define a basic message handler. In its simplest form,
[`on`](../lib/cinch/bot.rb) expects two arguments: The kind of message to react
to and the pattern to match. In this case, the kind is
[`:message`](events.md#message), which means that the bot will
respond to both messages in channels as well as messages sent directly
to the bot. For a list of all kinds, called events, see
[the list of events](events.md).

The string `"hello"` matches the entire message. Use a regular expression
when you need to match a pattern or extract part of the message:

```ruby
on :message, /\Ayear (\d{4})\z/ do |m, year|
  m.reply "You entered #{year}"
end
```

For `year 2026`, the handler receives the message and the captured string
`"2026"` as separate arguments.

The message object allows insight into the nature of the message, i.e.
who sent it, when was it sent etc, and also provides the
[`reply`](../lib/cinch/message.rb) method. It responds in the channel for
channel messages and directly to the user for private messages.

We use `reply` to send back "Hello, World" whenever someone says "hello".

That's it!

## on-handlers vs. plugins

Using `on` might be nice and handy for writing simple bots, but if you
want to write a more complex bot, providing lots of different features
to its users, then using plugins might be a better solution.

But what are plugins, exactly? Technically, plugins are implemented as
Ruby classes that mix-in a [specific module](../lib/cinch/plugin.rb) to get
access to various methods.

To have an example to work with, we'll convert our "Hello, World" bot
to using the plugin API:

```ruby
require "ircinch"

class HelloWorld
  include Cinch::Plugin

  match "hello"
  def execute(m)
    m.reply "Hello, World"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "my_example_bot"
    c.channels = ["#ircinch-bots"]
    c.plugins.plugins = [HelloWorld]
  end
end

bot.start
```

The `HelloWorld` class defines its handler with [`match`](../lib/cinch/plugin.rb).

But let's back up and proceed in smaller steps to see how plugins are built.

Including [`Cinch::Plugin`](../lib/cinch/plugin.rb) gives the class methods
like `match` and lets Cinch manage it as a plugin.

Then we use aforementioned `match`, instead of `on`, to specify what
messages we want to react to. We didn't have to specify the message
type because plugins default to [`:message`](events.md#message).

We then define a method called `execute`, which is pretty much the
same as blocks are to on-handlers. And from here on, everything is the
same.

The only thing left to do is to tell IRCinch to use our plugin, by
adding it to [`c.plugins.plugins`](bot_options.md#pluginsplugins).

One important thing remains to note: Plugins have a
[`prefix`](bot_options.md#pluginsprefix), a string (or pattern)
that gets prepended to all patterns you define, and by default this
prefix is `/^!/`. Send `!hello` to invoke the plugin. The [plugin guide](plugins.md#matching-messages)
shows how to change the prefix for a bot, plugin, or matcher.

## Final Words

This short guide only explains the basics of using IRCinch, so that you
can get started as quickly as possible. For more advanced topics, you
will want to read the specific documents:

- [Plugins](plugins.md)
- [A list of all available bot options](bot_options.md)
- [A list of all available events](events.md)
- [Dealing with encodings](encodings.md)
- [Logging in IRCinch](logging.md)
- [A cookbook for common tasks](common_tasks.md)
- [A list of common mistakes and how to avoid them](common_mistakes.md)
