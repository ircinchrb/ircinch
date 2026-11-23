# IRCinch - The IRC Bot Building Framework

## Description

IRCinch is an IRC Bot Building Framework for quickly creating IRC bots in
Ruby with minimal effort. It provides a simple interface based on plugins and
rules. It's as easy as creating a plugin, defining a rule, and watching your
profits flourish.

IRCinch will do all of the hard work for you, so you can spend time creating
cool plugins and extensions to wow your internet peers.

IRCinch is a fork of the brilliant [Cinch](https://github.com/cinchrb/cinch)
project by Dominik Honnef, Lee Jarvis, and contributors. The IRCinch fork
focuses on compatibility with supported versions of Ruby, and keeps the Ruby
API under the `Cinch` namespace for drop-in compatibility.

## Installation

This checkout requires Ruby 3.3 or newer. The
[CI matrix](.github/workflows/ci.yml) includes CRuby, JRuby, and TruffleRuby.

### RubyGems

You can install the latest IRCinch gem using RubyGems:

```sh
gem install ircinch
```

### Bundler

In an existing Bundler project, add IRCinch with:

```sh
bundle add ircinch
```

### GitHub

You can also check out the latest code directly from GitHub:

```sh
git clone https://github.com/ircinchrb/ircinch.git
```

## Example

Your typical "Hello, World" application in Cinch would go something like this:

```ruby
require "ircinch"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "my_example_bot"
    c.channels = ["#ircinch-bots"]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
  end
end

bot.start
```

See [Getting Started](docs/getting_started.md) for setup and how to run the
example. The [example bots](examples/README.md) include complete scripts
and commands to try.

## Features

### Documentation

See the [IRCinch guides](docs/readme.md) for setup, bot options, plugins, and
events.

For API details, see the [source reference](lib/cinch) or the gem's
[RubyDoc.info page](https://rubydoc.info/gems/ircinch).

### Object Oriented

Many IRC bots (and there are, **so** many) are great, but we see so little of
them take advantage of the awesome Object Oriented Interface which most Ruby
programmers will have become accustomed to and grown to love.

Well, IRCinch uses this functionality to its advantage. Rather than having to
pass around a reference to a channel or a user, to another method, which then
passes it to another method (by which time you're confused about what's
going on). IRCinch provides an OOP interface for even the simpliest of tasks,
making your code simple and easy to comprehend.

### Threaded

Unlike a lot of popular IRC frameworks, IRCinch is threaded. But wait, don't
let that scare you. It's totally easy to grasp.

IRCinch runs each handler invocation in its own thread and uses separate
threads for reading and writing IRC traffic. A plugin instance can handle
several events concurrently. Use [`synchronize`](docs/plugins.md#shared-state)
when handlers share mutable state.

### Plugins

That's right folks, IRCinch provides a modular based plugin system. This is a
feature many people have bugged us about for a long time. It's finally here,
and it's as awesome as you had hoped!

This system allows you to create feature packed plugins without interfering
with any of the Cinch internals. Everything in your plugin is self contained,
meaning you can share your favorite plugins among your friends and release a
ton of your own plugins for others to use.

Want to see the same Hello, World application in plugin form? Sure you do!

```ruby
require "ircinch"

class Hello
  include Cinch::Plugin

  match "hello"

  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick = "my_example_bot"
    c.channels = ["#cinch-bots"]
    c.plugins.plugins = [Hello]
  end
end

bot.start
```

Note: Plugins take a default prefix of `/^!/` which means the actual match is
`!hello`.

See the [plugin guide](docs/plugins.md) for matchers, listeners, and
configuration.

### Numeric Replies

Do you know what IRC code 401 represents? How about 376? or perhaps 502?
Sure you don't (and if you do, you're as geeky as us!). IRCinch doesn't expect
you to store the entire IRC RFC code set in your head, and rightfully so!

Use the named [constants](lib/cinch/constants.rb) in `Cinch::Constants`
or pass the numeric code directly to [`on` or `listen_to`](docs/events.md).

### Pretty Output

Ever get fed up of watching those boring, frankly unreadable lines flicker
down your terminal screen whilst your bot is online? Help is at hand! By
default, IRCinch uses a formatted logger that adds color when writing to a
terminal. Your plugins and handlers can also log custom messages:

```ruby
on :message, /hello/ do |m|
  debug "Someone said hello"
end
```

See [Logging](docs/logging.md) for levels, output, and filters.

## Code of Conduct

Everyone interacting in the IRCinch project's codebases, issue trackers, chat
rooms, and mailing lists is expected to follow the
[code of conduct](CODE_OF_CONDUCT.md).

## Contribute

Love IRCinch? Love Ruby? Love helping? Of course you do! If you feel like
IRCinch is missing that awesome jaw-dropping feature and you want to be the
one to make this magic happen, you can!

Fork the project, implement your awesome feature in its own branch, and send
a pull request to one of the IRCinch collaborators. We'll be more than happy
to check it out.

### Development

After forking/checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rake test` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `lib/cinch/version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
