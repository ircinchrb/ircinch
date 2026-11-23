# Encodings

IRC messages carry bytes without an encoding label. Configure
[`c.encoding`](bot_options.md#encoding) to control how IRCinch decodes
incoming bytes and encodes outgoing text.

## The `encoding` option

Use an encoding name such as `"UTF-8"`, a Ruby `Encoding` object such as
`Encoding::UTF_8`, or the special value `:irc` (the default).

```ruby
bot.configure do |c|
  c.encoding = Encoding::UTF_8
end
```

An explicit encoding applies in both directions. For example, use `"Windows-1252"`
for a network that expects that encoding on the wire.

## Encoding.default_internal

For explicit encodings, IRCinch passes incoming strings through Ruby's
`String#encode!`, which converts to `Encoding.default_internal` when it is
set. This Ruby setting is process-wide. `:irc` always returns incoming text
as UTF-8, regardless of `Encoding.default_internal`.

## The `:irc` encoding

- **Incoming** Keep valid UTF-8. If the byte sequence is invalid UTF-8,
  decode the whole line as Windows-1252 (CP1252) and convert it to UTF-8.
- **Outgoing** Encode as UTF-8, including text that could fit in CP1252.

## Invalid bytes and unsupported translations

IRCinch asks Ruby to replace invalid bytes or characters that cannot be
converted when it transcodes. The replacement depends on the destination
encoding. For an explicit incoming encoding, IRCinch discards characters
that are still invalid after the conversion step.

See the [encoding implementation](../lib/cinch/utilities/encoding.rb) and
[encoding tests](../test/lib/cinch/utilities/encoding.rb).
