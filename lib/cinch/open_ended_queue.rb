# frozen_string_literal: true

# Like Ruby's Queue class, but allowing both pushing and unshifting
# objects.
#
# @api private
class OpenEndedQueue
  def initialize
    @queue = []
    @mutex = Mutex.new
    @cv = ConditionVariable.new
  end

  def <<(obj)
    push(obj)
  end

  def push(obj)
    @mutex.synchronize do
      @queue.push(obj)
      @cv.signal
    end
  end

  def unshift(obj)
    @mutex.synchronize do
      @queue.unshift(obj)
      @cv.signal
    end
  end

  def pop(non_block = false)
    @mutex.synchronize do
      while @queue.empty?
        raise ThreadError, "queue empty" if non_block
        @cv.wait(@mutex)
      end
      @queue.shift
    end
  end
  alias shift pop
  alias deq pop
  alias enq push

  def empty?
    @mutex.synchronize { @queue.empty? }
  end

  def size
    @mutex.synchronize { @queue.size }
  end

  alias length size

  def clear
    @mutex.synchronize { @queue.clear }
  end
end
