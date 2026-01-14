require_relative "../../test_helper"
require "cinch/irc"

class IRCTest < TestCase
  class MockConfiguration
    attr_reader :timeouts, :ssl
    attr_accessor :server, :port, :local_host, :password, :nick, :user, :realname, :encoding, :modes
    
    def initialize
      @timeouts = OpenStruct.new(connect: 10, read: 10)
      @ssl = OpenStruct.new(use: false, verify: false)
      @server = "localhost"
      @port = 6667
      @local_host = nil
      @encoding = "UTF-8"
      @modes = []
    end
  end

  class MockLoggerList
    attr_reader :logs
    def initialize
      @logs = []
    end
    def warn(msg); @logs << msg; end
    def exception(e); @logs << e; end
    def info(msg); @logs << msg; end
    def debug(msg); @logs << msg; end
    def log(msg, level, group); @logs << msg; end
    def incoming(msg); end
    def outgoing(msg); end
  end

  class MockQueue
    def queue(msg); end
  end

  class MockList
    def initialize
      @list = {}
    end
    def find_ensured(name, *args)
      @list[name] ||= MockUser.new(name)
    end
  end

  class MockHandlers
    attr_reader :dispatched
    def initialize
      @dispatched = []
    end
    def dispatch(event, *args)
      @dispatched << event
    end
    def stop_all; end # used in start_reading_thread
  end

  # ... (MockBot definition remains, ensure it initializes MockHandlers)
  
  # ... existing tests ...

  test "parse triggers catchall" do
    @irc.parse("PING :foo")
    assert_includes @bot.handlers.dispatched, :catchall
  end

  test "parse dispatches private message events" do
    @irc.parse(":user!u@h PRIVMSG mybot :hello")
    assert_includes @bot.handlers.dispatched, :private
    assert_includes @bot.handlers.dispatched, :message
    refute_includes @bot.handlers.dispatched, :channel
  end

  test "parse handles numeric 001-004 as registration" do
    @irc.setup # reset state
    
    @irc.parse(":server 001 bot :Welcome")
    refute @irc.registered?
    @irc.parse(":server 002 bot :Your host")
    refute @irc.registered?
    @irc.parse(":server 003 bot :Created")
    refute @irc.registered?
    @irc.parse(":server 004 bot :info")
    assert @irc.registered?, "Should be registered after 004"
    
    assert_includes @bot.handlers.dispatched, :connect
  end
  
  test "send_login sends auth commands" do
    @bot.config.password = "secret"
    @bot.config.nick = "bot"
    @bot.config.user = "user"
    @bot.config.realname = "Real Name"
    # Generate next nick relies on config nicks or single nick
    
    # We need to spy on 'send'. The existing MockSocket approach is for 'connect'.
    # 'send' calls @queue.queue(msg).
    # We can stub @irc.send or look at @queue? 
    # @irc.instance_variable_get(:@queue) is nil because connect wasn't called.
    # IRCTest#setup calls IRC.new but not connect.
    
    # Let's stub send on @irc.
    sent = []
    @irc.define_singleton_method(:send) { |msg| sent << msg }
    
    @irc.__send__(:send_login)
    
    assert_includes sent, "PASS secret"
    assert_includes sent, "NICK bot"
    assert_includes sent, "USER user 0 * :Real Name"
  end
  
  test "send_cap_ls sends CAP LS" do
    sent = []
    @irc.define_singleton_method(:send) { |msg| sent << msg }
    @irc.__send__(:send_cap_ls)
    assert_includes sent, "CAP LS"
  end

  class MockBot
    attr_reader :config, :loggers, :user_list, :channel_list, :handlers, :channels
    attr_accessor :last_connection_was_successful, :online, :irc, :modes
    def initialize
      @config = MockConfiguration.new
      @loggers = MockLoggerList.new
      @user_list = MockList.new
      @channel_list = MockList.new
      @handlers = MockHandlers.new
      @channels = []
    end
    def generate_next_nick!; @config.nick; end
    def set_nick(nick); @config.nick = nick; end
    # Helpers rely on bot methods for delegates sometimes, but mainly uses lists
  end
  
  class MockUser
    attr_accessor :online, :channels_unsynced
    def initialize(name)
      @name = name
      @online = false
      @channels_unsynced = []
    end
    def sync(attribute, value, data=false); end
    def unsync_all; end
    def update_nick(new_nick); @name = new_nick; end
  end
  
  class MockChannel
    attr_reader :users, :name
    def initialize(name)
      @name = name
      @users = {}
    end
    def add_user(user, modes=[]); @users[user] = modes; end
    def remove_user(user); @users.delete(user); end
    def sync_modes; end
    def clear_users; @users.clear; end # for on_353
    def mark_as_synced(attr); end
  end

  class MockMessage
    attr_accessor :user, :channel, :message, :params, :command
    def initialize(user, message, channel=nil)
      @user = user
      @message = message
      @channel = channel
      @params = []
    end
    def channel?
      !!@channel
    end
  end
  
  # Stub for TCPSocket
  class MockSocket
    attr_accessor :read_timeout, :sync_close, :hostname, :sync
    def initialize(*args); end
    def close; end
    def connect; end
  end
  
  # Helper to stub constants/methods
  def with_stub(klass, method, behavior)
    metaclass = class << klass; self; end
    
    method_name = method.to_sym
    was_defined = metaclass.instance_methods(false).include?(method_name) || 
                  metaclass.private_instance_methods(false).include?(method_name)
    
    if was_defined
       original = klass.method(method_name)
       metaclass.send(:remove_method, method_name)
    end

    metaclass.send(:define_method, method_name) do |*args|
      behavior.call(*args)
    end
    
    yield
  ensure
    # Restore
    metaclass = class << klass; self; end
    
    # Always remove the stub we created
    if metaclass.instance_methods(false).include?(method_name) || 
       metaclass.private_instance_methods(false).include?(method_name)
      metaclass.send(:remove_method, method_name)
    end
    
    # If it was originally defined locally, restore it
    if was_defined && original
      metaclass.send(:define_method, method_name, original)
    end
  end

  def setup
    @bot = MockBot.new
    @irc = Cinch::IRC.new(@bot)
    @bot.irc = @irc
    @irc.instance_variable_set(:@queue, MockQueue.new)
    @irc.setup
  end

  test "initialize sets attributes" do
    assert_equal @bot, @irc.bot
    assert_instance_of Cinch::ISupport, @irc.isupport
  end

  test "setup initializes state" do
    @irc.setup
    assert_instance_of Cinch::Network, @irc.network
  end

  test "connect returns true on success" do
    mock_socket = MockSocket.new
    
    # Stub connection behavior
    socket_behavior = ->(*args) { mock_socket }
    buffered_behavior = ->(*args) { mock_socket }
    
    with_stub(TCPSocket, :new, socket_behavior) do
      with_stub(Net::BufferedIO, :new, buffered_behavior) do
        assert @irc.connect
      end
    end
  end

  test "connect returns false on timeout" do
    timeout_behavior = ->(*args) { raise Timeout::Error }
    
    with_stub(TCPSocket, :new, timeout_behavior) do
      refute @irc.connect
      assert_includes @bot.loggers.logs.last, "Timed out"
    end
  end

  test "connect returns false on socket error" do
    error_behavior = ->(*args) { raise SocketError, "conn refused" }
    
    with_stub(TCPSocket, :new, error_behavior) do
      refute @irc.connect
      assert_includes @bot.loggers.logs.last, "Could not connect"
    end
  end
  
  test "connect uses ssl if configured" do
    @bot.config.ssl.use = true
    @bot.config.ssl.verify = false
    
    mock_socket = MockSocket.new
    socket_behavior = ->(*args) { mock_socket }
    buffered_behavior = ->(*args) { mock_socket }
    
    # Stub Mock OpenSSL
    mock_ssl_context = Object.new
    def mock_ssl_context.verify_mode=(v); end
    def mock_ssl_context.ca_path=(v); end
    
    # We need to stub OpenSSL::SSL::SSLContext.new
    # Since OpenSSL is loaded dynamically in setup_ssl, we might need to ensure it is loaded first or stub safe.
    require "openssl"
    
    ssl_context_behavior = ->(*args) { mock_ssl_context }
    
    ssl_socket_behavior = ->(*args) { mock_socket }
    
    with_stub(OpenSSL::SSL::SSLContext, :new, ssl_context_behavior) do
      with_stub(OpenSSL::SSL::SSLSocket, :new, ssl_socket_behavior) do
        with_stub(TCPSocket, :new, socket_behavior) do
          with_stub(Net::BufferedIO, :new, buffered_behavior) do
             assert @irc.connect
             # We would assert mocks here but manual mocks don't record unless implemented
          end
        end
      end
    end
  end


  test "on_privmsg marks user online" do
    user = MockUser.new("foo")
    msg = MockMessage.new(user, "hello")
    
    @irc.__send__(:on_privmsg, msg, [])
    assert user.online
  end

  test "on_privmsg handles DCC SEND" do
    user = MockUser.new("foo")
    # \001DCC SEND "filename" ip port size\001
    text = "\001DCC SEND \"foo.txt\" 2130706433 1024 100\001"
    msg = MockMessage.new(user, text)
    events = []
    
    @irc.__send__(:on_privmsg, msg, events)
    assert_equal 1, events.size
    assert_equal :dcc_send, events.first[0]
    
    dcc = events.first[1]
    assert_equal "foo.txt", dcc.filename
    assert_equal 100, dcc.size
    assert_equal "127.0.0.1", dcc.ip
  end
  test "on_join adds user to channel" do
    user = MockUser.new("foo")
    channel = MockChannel.new("#chan")
    msg = MockMessage.new(user, "JOIN", channel)
    
    @irc.__send__(:on_join, msg, [])
    
    assert channel.users.key?(user)
    assert user.online
  end

  test "on_join tracks bot channels" do
    channel = MockChannel.new("#chan")
    msg = MockMessage.new(@bot, "JOIN", channel)
    
    @irc.__send__(:on_join, msg, [])
    
    assert_includes @bot.channels, channel
  end
  
  test "on_part removes user from channel" do
    user = MockUser.new("foo")
    channel = MockChannel.new("#chan")
    channel.add_user(user)
    msg = MockMessage.new(user, "PART", channel)
    
    @irc.__send__(:on_part, msg, [])
    
    refute channel.users.key?(user)
  end
  
  test "on_kick removes user from channel" do
    kicker = MockUser.new("op")
    victim = MockUser.new("victim")
    channel = MockChannel.new("#chan")
    channel.add_user(victim)
    
    msg = MockMessage.new(kicker, "KICK", channel)
    msg.params = ["#chan", "victim"]
    
    # helper User("victim") needs to resolve.
    # IRCTest defines MockList but assumes it returns name.
    # Helpers.rb User(name) -> bot.user_list.find_ensured(name)
    # MockList#find_ensured returns name (string).
    # But we want User object.
    
    # We need to stub User method or make MockList return objects?
    # Existing behavior: MockList returns name.
    # But on_kick calls: target = User(msg.params[1])
    # If MockList returns string, target is string.
    # Then msg.channel.remove_user(target) -> remove_user("victim")
    # But channel.add_user(victim) used the object.
    
    # To fix this, we should mock User helper or update MockList to return MockUser?
    # Updating MockList to return MockUser would be best but might break other tests?
    
    # Let's stub the User helper on @irc to return our victim object.
    
    # Valid Ruby way to stub on instance without minitest/mock
    @irc.define_singleton_method(:User) do |param|
      return victim if param == "victim"
      super(param)
    end
    
    @irc.__send__(:on_kick, msg, [])
    
    refute channel.users.key?(victim)
  end
end
