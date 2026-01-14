require_relative "../../../../test_helper"
require "cinch/dcc/incoming/send"
require "cinch/user"

class DccIncomingSendTest < TestCase
  class MockUser
  end

  class MockSocket
    attr_accessor :closed
    def initialize(*args); @closed = false; end
    # Simulate data read
    def readpartial(size)
      if @read_done
        nil # EOF
      else
        @read_done = true
        "file content"
      end
    end
    def write_nonblock(data); end
    def close; @closed = true; end
  end

  def setup
    @user = MockUser.new
    @dcc = Cinch::DCC::Incoming::Send.new(
      user: @user,
      filename: "/tmp/foo.txt",
      size: 12,
      ip: "127.0.0.1",
      port: 12345
    )
  end

  test "attributes are set correctly" do
    assert_equal @user, @dcc.user
    assert_equal "foo.txt", @dcc.filename # sanitization
    assert_equal 12, @dcc.size
    assert_equal "127.0.0.1", @dcc.ip
    assert_equal 12345, @dcc.port
  end

  test "filename sanitizes slashes" do
    dcc = Cinch::DCC::Incoming::Send.new(
      user: @user,
      filename: "../../../tmp/foo.txt",
      size: 10,
      ip: "1.1.1.1",
      port: 80
    )
    assert_equal "foo.txt", dcc.filename
    
    dcc2 = Cinch::DCC::Incoming::Send.new(
      user: @user,
      filename: "C:\\temp\\foo.txt",
      size: 10,
      ip: "1.1.1.1",
      port: 80
    )
    # On non-Windows, File.basename won't split by \, so they are just removed.
    # We verify that they are removed at least.
    expected = RUBY_PLATFORM =~ /mswin|mingw|cygwin/ ? "foo.txt" : "C:tempfoo.txt"
    assert_equal expected, dcc2.filename
  end

  test "accept downloads data" do
    mock_socket = MockSocket.new
    io = StringIO.new
    
    with_stub(TCPSocket, :new, ->(ip, port) { 
      assert_equal "127.0.0.1", ip
      assert_equal 12345, port
      mock_socket 
    }) do
      result = @dcc.accept(io)
      assert result
      assert_equal "file content", io.string
      assert mock_socket.closed
    end
  end

  test "private ip detection" do
    dcc = Cinch::DCC::Incoming::Send.new(ip: "192.168.1.50", port: 1, filename: "a", size: 1, user: @user)
    assert dcc.from_private_ip?
    
    dcc2 = Cinch::DCC::Incoming::Send.new(ip: "8.8.8.8", port: 1, filename: "a", size: 1, user: @user)
    refute dcc2.from_private_ip?
  end

  test "localhost detection" do
    dcc = Cinch::DCC::Incoming::Send.new(ip: "127.0.0.1", port: 1, filename: "a", size: 1, user: @user)
    assert dcc.from_localhost?
    
    dcc2 = Cinch::DCC::Incoming::Send.new(ip: "8.8.8.8", port: 1, filename: "a", size: 1, user: @user)
    refute dcc2.from_localhost?
  end
end
