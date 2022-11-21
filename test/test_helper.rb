# frozen_string_literal: true

if ENV["SIMPLECOV"]
  begin
    require "simplecov"
    SimpleCov.start
  rescue LoadError
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ircinch"

require "minitest/autorun"

class TestCase < MiniTest::Test
  def self.test(name, &block)
    define_method("test_" + name, &block) if block
  end
end
