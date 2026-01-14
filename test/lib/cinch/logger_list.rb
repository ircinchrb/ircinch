require_relative "../../test_helper"
require "cinch/logger_list"

class LoggerListTest < TestCase
  class MockLogger
    attr_reader :logs, :level
    def initialize
      @logs = []
      @level = :debug
    end
    def level=(l); @level = l; end
    def log(messages, event, level)
      @logs << [:log, messages, event, level]
    end
    def debug(m); @logs << [:debug, m]; end
    def info(m); @logs << [:info, m]; end
    def error(m); @logs << [:error, m]; end
  end

  class MockFilter
    def filter(msg, event)
      if msg == "block_me"
        nil
      elsif msg == "modify_me"
        "modified"
      else
        msg
      end
    end
  end

  def setup
    @list = Cinch::LoggerList.new
    @logger1 = MockLogger.new
    @logger2 = MockLogger.new
    @list << @logger1
    @list << @logger2
  end

  test "level= updates all loggers" do
    @list.level = :warn
    assert_equal :warn, @logger1.level
    assert_equal :warn, @logger2.level
  end

  test "log delegates to all loggers" do
    @list.log("msg", :evt, :lvl)
    assert_equal [:log, ["msg"], :evt, :lvl], @logger1.logs.last
    assert_equal [:log, ["msg"], :evt, :lvl], @logger2.logs.last
  end

  test "debug/info delegates to all loggers" do
    @list.debug("dbg")
    assert_equal [:debug, "dbg"], @logger1.logs.last
    
    @list.info("inf")
    assert_equal [:info, "inf"], @logger1.logs.last
  end

  test "filters modify or block messages" do
    @list.filters << MockFilter.new
    
    @list.debug("block_me")
    assert_nil @logger1.logs.last
    assert_empty @logger1.logs
    
    @list.debug("modify_me")
    assert_equal [:debug, "modified"], @logger1.logs.last
  end
end
