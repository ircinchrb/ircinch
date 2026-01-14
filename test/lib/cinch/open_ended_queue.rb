require_relative "../../test_helper"
require "cinch/open_ended_queue"

class OpenEndedQueueTest < TestCase
  def setup
    @queue = OpenEndedQueue.new
  end

  test "should behave like a normal queue" do
    @queue << 1
    @queue << 2
    assert_equal 1, @queue.shift
    assert_equal 2, @queue.shift
  end

  test "unshift should add to the front" do
    @queue << 1
    @queue.unshift(2)
    assert_equal 2, @queue.shift
    assert_equal 1, @queue.shift
  end
  
  test "unshift should wake up waiting threads" do
    t = Thread.new { @queue.shift }
    # Give the thread time to block
    Thread.pass
    sleep 0.1
    
    @queue.unshift(:woke)
    assert_equal :woke, t.value
  end

  test "pop(true) raises ThreadError if empty" do
    assert_raises(ThreadError) { @queue.pop(true) }
  end

  test "size and length return count" do
    assert_equal 0, @queue.size
    @queue << 1
    assert_equal 1, @queue.size
    assert_equal 1, @queue.length
  end

  test "empty? checks emptiness" do
    assert @queue.empty?
    @queue << 1
    refute @queue.empty?
  end

  test "clear empties the queue" do
    @queue << 1
    @queue.clear
    assert @queue.empty?
  end
end
