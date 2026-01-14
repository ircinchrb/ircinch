# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ircinch"

require "minitest/autorun"

class TestCase < Minitest::Test
  def self.test(name, &block)
    define_method("test_" + name, &block) if block
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
end
