# frozen_string_literal: true

require_relative "../../../../test_helper"
require "cinch/dcc/outgoing/send"
require "cinch/user"

class DccOutgoingSendTest < TestCase
  class MockUser
    attr_reader :sent
    def initialize
      @sent = []
    end

    def send(msg)
      @sent << msg
    end
  end

  class MockTCPServer
    attr_reader :closed
    def initialize(*args)
    end

    def listen(n)
    end

    def addr
      [nil, 12345]
    end

    def accept
      # Return [client_fd, addr_info]
      [MockClient.new, nil]
    end

    def close
      @closed = true
    end
  end

  class MockClient
    attr_reader :received
    def initialize
      @received = +""
      @closed = false
    end

    # Simulate partial reads and writes
    # For readability check
    def recv(size)
      ""
    end

    def write(data)
      @received << data
      data.bytesize
    end

    def close
      @closed = true
    end

    # For IO.select
    def to_io
      self
    end
  end

  def setup
    @receiver = MockUser.new
    @io = StringIO.new("test content")
    # Mock advise support
    def @io.advise(*args)
    end
    @sender = Cinch::DCC::Outgoing::Send.new(
      receiver: @receiver,
      filename: "test.txt",
      io: @io,
      own_ip: "127.0.0.1"
    )
  end

  test "initialize sets attributes" do
    assert_equal 0, @io.pos
  end

  test "start_server creates socket" do
    # Stub TCPServer.new
    mock_server = MockTCPServer.new
    with_stub(TCPServer, :new, ->(*args) { mock_server }) do
      @sender.start_server
      assert_equal 12345, @sender.port
    end
  end

  test "send_handshake sends correct string" do
    # Requires port to be set (via start_server or manually)
    # We can fake it by mocking internal state or just mocking start_server

    mock_server = MockTCPServer.new
    with_stub(TCPServer, :new, ->(*args) { mock_server }) do
      @sender.start_server
      @sender.send_handshake

      # Handshake: \001DCC SEND filename ip port size\001
      # IP 127.0.0.1 -> 2130706433
      expected = "\001DCC SEND test.txt 2130706433 12345 12\001"
      assert_equal expected, @receiver.sent.first
    end
  end

  test "listen transfers data" do
    mock_server = MockTCPServer.new
    mock_client = MockClient.new

    # Hook accept to return our specific client
    def mock_server.accept
      [@my_client, nil]
    end
    mock_server.instance_variable_set(:@my_client, mock_client)

    # We must ensure IO.select works. MockClient is not a real IO.
    # IO.select([fd]) calls fd.to_io ??
    # Actually IO.select expects IO objects.
    # So MockClient must duck type or we must stub IO.select.

    with_stub(TCPServer, :new, ->(*args) { mock_server }) do
      with_stub(IO, :select, ->(*args) { [[mock_client], [mock_client]] }) do
        @sender.start_server
        @sender.listen

        assert_equal "test content", mock_client.received
        assert mock_server.closed
      end
    end
  end

  # Stub helper from IRCTest (reuse or redefine)
  def with_stub(klass, method, behavior)
    metaclass = class << klass; self; end
    method_name = method.to_sym
    was_defined = metaclass.method_defined?(method_name, false) ||
      metaclass.private_method_defined?(method_name, false)

    if was_defined
      original = klass.method(method_name)
      metaclass.send(:remove_method, method_name)
    end

    metaclass.send(:define_method, method_name) do |*args|
      behavior.call(*args)
    end

    yield
  ensure
    if metaclass.method_defined?(method_name, false) ||
        metaclass.private_method_defined?(method_name, false)
      metaclass.send(:remove_method, method_name)
    end

    if was_defined && original
      metaclass.send(:define_method, method_name, original)
    end
  end
end
