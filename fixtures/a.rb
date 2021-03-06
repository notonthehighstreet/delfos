# frozen_string_literal: true
require_relative "b"

class A
  def some_method
    B.new.another_method(self) # cs1 e-step1
    C.new.method_with_no_more_method_calls # cs3 e-step
    D.some_class_method
  end

  def to_s
    "a"
  end

  def self.boom!
    raise "kaboom"
  end
end

class D
  def self.some_class_method

  end
end
