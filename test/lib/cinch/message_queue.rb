require_relative "../../test_helper"
require "cinch/message_queue"
require "cinch/configuration/bot"

class MessageQueueTest < TestCase
  class MockSocket
    attr_reader :writes
    def initialize; @writes = []; end
    def write(data); @writes << data; end
  end

  class MockBot
    attr_reader :config, :loggers, :irc
    def initialize
      @config = Cinch::Configuration::Bot.new
      @loggers = MockLoggerList.new
      @irc = OpenStruct.new(network: OpenStruct.new(default_messages_per_second: 1000, default_server_queue_size: 10))
    end
  end
  class MockLoggerList
    def outgoing(msg); end
    def error(msg); end
  end

  def setup
    @socket = MockSocket.new
    @bot = MockBot.new
    @queue = Cinch::MessageQueue.new(@socket, @bot)
  end

  test "queue adds to generic queue for non-privmsg" do
    @queue.queue("PING :foo")
    
    # We inspect internal state via instance variable for verification
    queues = @queue.instance_variable_get(:@queues)
    assert_equal 1, queues[:generic].size
  end

  test "queue adds to target queue for privmsg" do
    @queue.queue("PRIVMSG #chan :hello")
    
    queues = @queue.instance_variable_get(:@queues)
    assert_equal 1, queues["#chan"].size
    assert_empty queues[:generic]
  end

  test "process_one writes to socket" do
    @queue.queue("PING :foo")
    @queue.send(:process_one)
    
    assert_equal "PING :foo\r\n", @socket.writes.last
  end

  test "process_one encodes outgoing message" do
    @bot.config.encoding = :irc # defaults to UTF-8
    str = "foo\u1234" # UTF-8 char
    @queue.queue("PRIVMSG #chan :#{str}")
    @queue.send(:process_one)
    
    last_write = @socket.writes.last
    # encode_outgoing returns binary string
    expected = "PRIVMSG #chan :#{str}".force_encoding("ASCII-8BIT") + "\r\n"
    assert_equal expected, last_write
    assert_equal Encoding::ASCII_8BIT, last_write.encoding
  end
  
  test "waits for rate limiting" do
    # Configure 1 message per second
    @bot.config.messages_per_second = 1
    @bot.config.server_queue_size = 10
    
    # Simulate a full log
    log = []
    10.times { log << Time.now } # 0 delay
    @queue.instance_variable_set(:@log, log)
    
    # Expect sleep to be called
    @queue.define_singleton_method(:sleep) { |duration| @slept = duration }
    
    @queue.send(:wait)
    
    assert_in_delta 1.0, @queue.instance_variable_get(:@slept), 0.1
  end

  test "process_one handles IOError" do
    def @socket.write(*)
      raise IOError, "closed stream"
    end
    
    # Spy on logger
    errors = []
    @bot.loggers.define_singleton_method(:error) { |msg| errors << msg }
    
    @queue.queue("PING :foo")
    @queue.send(:process_one)
    
    assert_includes errors.join, "Could not send message"
  end
end
