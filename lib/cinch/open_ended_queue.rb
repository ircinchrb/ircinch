# frozen_string_literal: true

# Like Ruby's Queue class, but allowing both pushing and unshifting
# objects.
#
# @api private
class OpenEndedQueue < Queue
  # @param [Object] obj
  # @return [void]
  def unshift(obj)
    t = nil
    @mutex.synchronize {
      @que.unshift obj
      begin
        t = @waiting.shift
        t&.wakeup
      rescue ThreadError
        retry
      end
    }
    begin
      t&.run
    rescue ThreadError
    end
  end
end
