# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/logger"

class LoggerTest < TestCase
  def setup
    @output = StringIO.new
    @logger = Cinch::Logger.new(@output)
  end

  test "defaults to debug level" do
    assert_equal :debug, @logger.level
  end

  test "will_log? checks level order" do
    @logger.level = :warn

    refute @logger.will_log?(:debug)
    refute @logger.will_log?(:info)
    assert @logger.will_log?(:warn)
    assert @logger.will_log?(:error)
    assert @logger.will_log?(:fatal)
  end

  test "log writes to output if level sufficient" do
    @logger.level = :info
    @logger.log("test message", :info)
    assert_match "test message", @output.string
  end

  test "log does not write if level insufficient" do
    @logger.level = :warn
    @logger.log("test message", :info)
    assert_empty @output.string
  end

  test "debug/info/warn/error/fatal helpers" do
    @logger.level = :debug
    @logger.debug("d")
    @logger.info("i")
    @logger.warn("w")
    @logger.error("e")
    @logger.fatal("f")

    out = @output.string
    assert_match "d", out
    assert_match "i", out
    assert_match "w", out
    assert_match "e", out
    assert_match "f", out
  end

  test "incoming logs as :log level" do
    @logger.level = :log # :log is between :debug and :info logic-wise in LEVEL_ORDER?
    # LEVEL_ORDER = [:debug, :log, :info, :warn, :error, :fatal]

    @logger.incoming("in")
    assert_match "in", @output.string
  end

  test "outgoing logs as :log level" do
    @logger.outgoing("out")
    assert_match "out", @output.string
  end

  test "exception logs as error" do
    @logger.level = :error
    @logger.exception(StandardError.new("oops"))
    assert_match "oops", @output.string
  end
end
