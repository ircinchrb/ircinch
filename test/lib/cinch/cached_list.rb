# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/cached_list"

class CachedListTest < TestCase
  def setup
    @bot = Object.new
    @list = Cinch::CachedList.new(@bot)
  end

  test "is enumerable" do
    assert_includes Cinch::CachedList.ancestors, Enumerable
  end

  test "can iterate" do
    # Implementation of each uses @cache.each_value
    # @cache is empty by default
    count = 0
    @list.each { count += 1 }
    assert_equal 0, count
  end
end
