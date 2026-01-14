require_relative "../../../test_helper"
require "cinch/logger/formatted_logger"
require "stringio"

class FormattedLoggerTest < TestCase
  def setup
    @io = StringIO.new
    @logger = Cinch::Logger::FormattedLogger.new(@io)
  end

  test "exception logs backtrace" do
    begin
      raise "test error"
    rescue => e
      @logger.exception(e)
    end
    
    output = @io.string
    assert_match "test error", output
    assert_match "FormattedLoggerTest", output
  end

  test "format_general logs printable" do
    @logger.log("test message", :debug)
    assert_match "test message", @io.string
  end

  test "format_general escapes non-printable on tty" do
    # Verify tty behavior by mocking tty?
    def @io.tty?; true; end
    
    @logger.log("foo\x00bar", :debug)
    # \x00 should be replaced/colorized
    output = @io.string
    assert_match "foo", output
    assert_match "bar", output
    # checking for escape sequence for bg_white (\e[47m)
    assert_match "\e[47m", output
  end

  test "format_debug adds timestamp" do
    @logger.log("debug info", :debug)
    assert_match(/\[\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}\.\d{3}\]/, @io.string)
    assert_match "debug info", @io.string
  end

  test "format_incoming formats message" do
    # Format: :prefix command params :message
    msg = ":nick!user@host PRIVMSG #channel :hello world"
    @logger.log(msg, :incoming, :log)
    
    assert_match "nick!user@host", @io.string
    assert_match "PRIVMSG", @io.string
    assert_match "#channel", @io.string
    assert_match "hello world", @io.string
    
    # Check green arrow ">>" if tty
    def @io.tty?; true; end
    @io.truncate(0)
    @io.rewind
    @logger.log(msg, :incoming, :log)
    assert_match "\e[32m>>\e[0m", @io.string
  end

  test "format_outgoing formats message" do
    msg = "PRIVMSG #channel :hello world"
    @logger.log(msg, :outgoing, :log)
    
    assert_match "PRIVMSG", @io.string
    assert_match "<<", @io.string
  end
  
  test "colorize works only on tty - true" do
    def @io.tty?; true; end
    @logger.log("test", :debug)
    assert_match "\e[", @io.string
  end

  test "colorize works only on tty - false" do
    def @io.tty?; false; end
    @logger.log("test", :debug)
    refute_match "\e[", @io.string
  end

  test "format_warn logs with !!" do
    @logger.log("warn msg", :warn)
    assert_match "!! warn msg", @io.string
  end

  test "format_info logs with II" do
    @logger.log("info msg", :info)
    assert_match "II info msg", @io.string
  end

  test "format_incoming handles messages without prefix" do
    # e.g. PING :host
    msg = "PING :host.net"
    @logger.log(msg, :incoming, :log)
    assert_match "PING", @io.string
    assert_match "host.net", @io.string
  end
end
