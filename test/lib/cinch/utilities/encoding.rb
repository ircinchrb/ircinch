# frozen_string_literal: true

require_relative "../../../test_helper"
require "cinch/utilities/encoding"

class EncodingTest < TestCase
  test "encode_incoming handles valid utf8 when encoding is :irc" do
    str = (+"foo\u1234").force_encoding("UTF-8")
    assert str.valid_encoding?

    res = Cinch::Utilities::Encoding.encode_incoming(str, :irc)
    assert_equal str, res
    assert_equal Encoding::UTF_8, res.encoding
  end

  test "encode_incoming handles invalid utf8 (cp1252) when encoding is :irc" do
    # 0xE9 in CP1252 is é. In UTF-8 it's invalid start byte.
    str = (+"\xE9").force_encoding("UTF-8")
    refute str.valid_encoding?

    res = Cinch::Utilities::Encoding.encode_incoming(str, :irc)
    assert_equal "é", res
    assert_equal Encoding::UTF_8, res.encoding
  end

  test "encode_incoming forces encoding for other encodings" do
    # When not :irc, it tries to force encoding and scrub
    str = (+"foo").force_encoding("ASCII-8BIT")
    res = Cinch::Utilities::Encoding.encode_incoming(str, "UTF-8")
    assert_equal "foo", res
    assert_equal Encoding::UTF_8, res.encoding
  end

  test "encode_outgoing encodes to target and binary" do
    str = "foo"
    res = Cinch::Utilities::Encoding.encode_outgoing(str, :irc)
    # :irc -> UTF-8 -> ASCII-8BIT (binary)
    assert_equal "foo", res
    assert_equal Encoding::ASCII_8BIT, res.encoding

    str2 = "é"
    res2 = Cinch::Utilities::Encoding.encode_outgoing(str2, :irc)
    assert_equal Encoding::ASCII_8BIT, res2.encoding
    assert_equal "\xC3\xA9".b, res2 # UTF-8 representation in binary
  end
end
