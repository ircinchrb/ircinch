# Plugins

A plugin is a Ruby class that includes `Cinch::Plugin`. IRCinch creates an
instance for each bot that registers the plugin. Add the class to
[`c.plugins.plugins`](bot_options.md#pluginsplugins) before `bot.start`.
See the [complete Hello, World bot](getting_started.md#on-handlers-vs-plugins).

## Matching messages

`match` reacts to `:message` by default and calls `execute(message, *captures)`.
Pass `method:` to select a different method and `react_on:` to select a
specific [event](events.md). A string matches the entire message after
including the prefix and suffix. A regular expression keeps its own anchors,
with the prefix and suffix applied around it.

```ruby
class Echo
  include Cinch::Plugin

  match /\Aecho (.+)\z/, use_prefix: false, method: :echo

  def echo(message, text)
    message.safe_reply(text)
  end
end
```

Plugin matchers inherit the bot prefix (`/^!/` by default) and suffix
(`nil` by default). Override either with `set :prefix, ...` or
`set :suffix, ...`, or pass `prefix:` and `suffix:` on an individual
matcher. Set `use_prefix: false` or `use_suffix: false` to omit either.
A `Proc` used as a pattern, prefix, or suffix receives the message and
returns the value to match. `strip_colors: true` requests matching against
text with IRC formatting removed. A `group:` limits a match group to
its first matching handler for a dispatch.

## Listening to events

Use `listen_to` to react to events without filtering by text. It accepts one
or more event names and calls `listen` unless `method:` selects another method.
Arguments depend on the [event](events.md).

```ruby
listen_to :join, :part, method: :track_membership

def track_membership(message)
  info "#{message.command}: #{message.user} in #{message.channel}"
end
```

For CTCP commands, `ctcp "VERSION"` registers `ctcp_version(message)`.
Use `message.ctcp_reply(text)` to send a reply.

## Configuration

Set options on the bot and read them through the plugin instance's `config`
hash. `required_options` lists keys that must be present before the plugin's
handlers are registered. Validate the values separately if needed.

```ruby
class Greeting
  include Cinch::Plugin

  set :required_options, [:text]
  match "hello"

  def execute(message)
    message.reply(config.fetch(:text))
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.plugins.plugins = [Greeting]
    c.plugins.options[Greeting] = {text: "Hello!"}
  end
end
```

If the plugin defines `initialize(bot)`, call `super` to register its
handlers. See [common mistakes](common_mistakes.md).

Use `set :help, "Description of the command"` to add a help response.
With the default prefix, a plugin called `Greeting` responds to `!help greeting`.

## Hooks and timers

Use `hook :pre` or `hook :post` to run a method before or after a handler
in its thread. `method:` names the hook method. `for:` limits it to
`:match`, `:listen_to`, or `:ctcp`, and `group:` limits it to a matcher
group. The hook receives the message. Returning `false` from a pre-hook
skips that handler. Returning `false` from a post-hook stops later post-hooks.

Declare a repeating task with `timer 30, method: :tick`. The method takes
no arguments. The timer starts on `:connect` and stops on `:disconnect` by
default. Use `shots:` to limit the number of invocations. `threaded: false`
runs each invocation on the timer thread before waiting for the next interval.

For a timer started from a handler, call `Timer(5, shots: 1, start_automatically: false) { ... }`.
The helper starts it immediately and returns a timer object you can stop.

## Shared state

Separate invocations of a plugin handler can run concurrently on the same
plugin instance. Use `synchronize(:name) { ... }` when reading and writing
state that handlers share. Plugins attached to the same bot can also use
[`shared`](bot_options.md#shared) and a common synchronization name.

See the [`Cinch::Plugin` API source](../lib/cinch/plugin.rb) and
[`Cinch::Timer` API source](../lib/cinch/timer.rb).
