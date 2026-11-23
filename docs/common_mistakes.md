# Common Mistakes

## I defined an initialize method in my plugin and now it doesn't work properly anymore

IRCinch passes the bot to the plugin initializer. Call `super` with that
argument so `Cinch::Plugin` can initialize the instance and register its
handlers.

### Example

```ruby
class MyPlugin
  include Cinch::Plugin

  def initialize(bot)
    super
    @seen = {}
  end
end
```

## I am trying to use plugin options, but Ruby says it cannot find the `config` method

`config` belongs to the plugin instance. Class-level declarations run before
the class is registered with a bot, so `match(config[:pattern])` raises.
Define a static matcher and check the configured value in the handler, as
shown in [plugin configuration](plugins.md#configuration).

## My handlers won't run, even though the regular expression matches

IRCinch plugins have a default prefix (`/^!/`). This allows for flexible prefixes
across the whole bot. The default prefix can be changed in `Bot#configure`:

```ruby
bot = Cinch::Bot.new do
  configure do |c|
    # ...
    c.plugins.prefix = /^%/
  end
end
```

Alternatively, you can set the prefix for specific plugins only, by calling `set`:

```ruby
class MyPlugin
  include Cinch::Plugin

  set :prefix, /^%/
end
```

You can also choose to not use a prefix for specific matchers:

```ruby
match /hi/, use_prefix: false
```

## My bot hasn't joined a channel when `:connect` runs

`:connect` signals IRC registration. The channel joins happen afterward.
Listen for `:join` and check `m.user == bot` before relying on membership.
See [`:connect`](events.md#connect) and [`delay_joins`](bot_options.md#delay_joins).

## Setting `c.default_logger_level` didn't change my log output

The default logger already exists when the configuration block runs. Set
`bot.loggers.first.level = :info` before `bot.start` to change its level.
See [Logging](logging.md#changing-the-level).
