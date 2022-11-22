# frozen_string_literal: true

unless Float.const_defined?(:INFINITY)
  Float::INFINITY = 1.0 / 0.0
end
