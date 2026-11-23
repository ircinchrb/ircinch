# IRCinch Examples

The scripts in `basic/` use `bot.on` handlers. The scripts in `plugins/` register
classes that include `Cinch::Plugin`. Run one script at a time in a channel
where you have permission to test.

From the repository root, run `bundle install`, then start an example:

```sh
IRC_SERVER=localhost IRC_CHANNEL='#my-test-channel' IRC_NICK=mybot \
  bundle exec ruby -Ilib examples/basic/hello.rb
```

Join the same channel with an IRC client and send `hello`. The plugin version
responds to `!hello`. Ctrl-C stops either bot. With the gem installed directly,
you can also run `ruby examples/basic/hello.rb` and use the installed gem.

The examples default to `localhost`, port `6667`, and `#ircinch-bots`.
Set `IRC_SERVER`, `IRC_PORT`, `IRC_CHANNEL`, and `IRC_NICK` for your test
server. Set `IRC_TLS=1` to enable TLS and certificate-chain verification,
with port `6697` as the default. See [TLS behavior](../docs/bot_options.md#sslverify).

## Commands and Events

- [Hello (basic)](basic/hello.rb) and [plugin](plugins/hello.rb). Send `hello`
  to the basic bot or `!hello` to the plugin to get a greeting.
- [Autovoice (basic)](basic/autovoice.rb) and [plugin](plugins/autovoice.rb).
  Give the bot operator mode (`+o`), send `!autovoice on` as a channel
  operator, then have another user join. `!autovoice off` disables it in
  that channel.
- [Google (basic)](basic/google.rb) and [plugin](plugins/google.rb).
  Send `!google ruby irc` to get a search link.
- [Join and part (basic)](basic/join_part.rb) and [plugin](plugins/join_part.rb).
  Send `!join #another-channel`, then `!part #another-channel`. In a channel,
  `!part` uses that channel.
- [Memo](basic/memo.rb). Send `!memo alice Hello`, then have Alice send a
  message the bot can see. The bot delivers the memo by private message.
- [Message relay (basic)](basic/msg.rb) and [plugin](plugins/msg.rb).
  Send `!msg alice Hello` to have the bot send Alice a private message.
- [Seen (basic)](basic/seen.rb) and [plugin](plugins/seen.rb). Have Alice say
  something in the channel, then send `!seen alice` to recall her latest
  public message in that channel.
- [Urban Dictionary](basic/urban_dict.rb). Send `!urban example` to get a
  definition link.
- [URL shortener (basic)](basic/url_shorten.rb) and [plugin](plugins/url_shorten.rb).
  Send `!shorten https://example.com` to get a TinyURL link.
- [Custom prefix](plugins/custom_prefix.rb). Send `~somecommand` to try a
  plugin-specific command prefix.
- [Dice roll](plugins/dice_roll.rb). Send `!roll 2d6+1` to roll two six-sided
  dice and add one to each die. `!roll 2#3d6` rolls six dice and totals them.
  A command can roll up to 100 dice with at most 10,000 sides each.
- [Hooks](plugins/hooks.rb). Send `!rand` to run pre- and post-hooks around
  the command handler in the same thread.
- [Dynamic prefix](plugins/lambdas.rb). Send `mybot: hello`, using the bot's
  current nickname. An authorized sender can send `mybot: rename` to append
  `_` to the bot's nick.
- [Last nick](plugins/last_nick.rb). Change nick while sharing the bot's
  channel to get a private message with your previous nick.
- [Multiple matches](plugins/multiple_matches.rb). Send `!command1 one`,
  `!command2 two`, or `command3 three` to route to different methods.
- [Custom events](plugins/own_events.rb). Wait for a periodic random number
  after the bot joins. One plugin publishes the event and the other replies.
- [Timer](plugins/timer.rb). Wait for the message the bot sends every five
  seconds after joining.

## Extra Setup

- **Join, part, relay, and rename.** Set `IRC_ADMIN_PREFIX` to your exact
  IRC sender prefix, with no leading colon, such as `alice!ident@trusted.example`.
  The examples compare against the prefix supplied by the server. Use a test
  network where that prefix identifies only your client. An unset value disables
  those commands.
- **URL shortener.** Set `TINYURL_TOKEN` to a TinyURL API token with permission
  to create links. Each `!shorten` request sends the URL to TinyURL and uses the
  token's quota. [TinyURL API token setup](https://tinyurl.com/blog/how-create-modify-api-token/)
- **Memo and seen.** State stays in memory until the bot exits. Memos are
  addressed to nicknames, which IRC users can change or reuse. Use non-sensitive
  sample text.
