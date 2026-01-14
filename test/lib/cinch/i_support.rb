require_relative "../../test_helper"
require "cinch/i_support"

class ISupportTest < TestCase
  def setup
    @isupport = Cinch::ISupport.new
  end

  test "defaults are set correctly" do
    assert_equal({"o" => "@", "v" => "+"}, @isupport["PREFIX"])
    assert_equal ["#"], @isupport["CHANTYPES"]
    assert_equal 1, @isupport["MODES"]
    assert_equal Float::INFINITY, @isupport["NICKLEN"]
    assert_instance_of Hash, @isupport["CHANMODES"]
    assert_equal :rfc1459, @isupport["CASEMAPPING"]
  end

  test "parse updates prefix" do
    @isupport.parse("PREFIX=(qaohv)~&@%+")
    expected = {
      "q" => "~",
      "a" => "&",
      "o" => "@",
      "h" => "%",
      "v" => "+"
    }
    assert_equal expected, @isupport["PREFIX"]
  end

  test "parse updates chanmodes" do
    @isupport.parse("CHANMODES=I,k,H,D")
    expected = {
      "A" => ["I"],
      "B" => ["k"],
      "C" => ["H"],
      "D" => ["D"]
    }
    # Note: parsing splits by comma and assigns to A, B, C, D
    assert_equal expected, @isupport["CHANMODES"]
  end

  test "parse updates numeric limits" do
    @isupport.parse("NICKLEN=9", "MAXCHANNELS=20", "TOPICLEN=300")
    assert_equal 9, @isupport["NICKLEN"]
    assert_equal 20, @isupport["MAXCHANNELS"]
    assert_equal 300, @isupport["TOPICLEN"]
  end

  test "parse updates chanlimit" do
    @isupport.parse("CHANLIMIT=#:120,&:10")
    expected = {
      "#" => 120,
      "&" => 10
    }
    assert_equal expected, @isupport["CHANLIMIT"]
  end

  test "parse updates targmax" do
    @isupport.parse("TARGMAX=PRIVMSG:4,NOTICE:3")
    expected = {
      "PRIVMSG" => 4,
      "NOTICE" => 3
    }
    assert_equal expected, @isupport["TARGMAX"]
  end

  test "parse updates array types" do
    @isupport.parse("CHANTYPES=#&", "STATUSMSG=@+")
    assert_equal ["#", "&"], @isupport["CHANTYPES"]
    assert_equal ["@", "+"], @isupport["STATUSMSG"]
  end

  test "parse handles boolean flags" do
    @isupport.parse("NAMESX", "UHNAMES")
    assert @isupport["NAMESX"]
    assert @isupport["UHNAMES"]
  end
  
  test "parse handles casemapping" do
    @isupport.parse("CASEMAPPING=ascii")
    assert_equal :ascii, @isupport["CASEMAPPING"]
  end
end
