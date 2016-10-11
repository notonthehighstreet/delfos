# frozen_string_literal: true
require_relative "patching"

class BasicObject
  def self.inherited(sub_klass)
    return if self == ::BasicObject or self == ::Object

    ::Delfos::Patching.notify_inheritance(self, sub_klass)
  end

  def self.method_added(name)
    return if name == __method__

    ::Delfos::Patching.perform(self, name, private_instance_methods, class_method: false)
  end

  def self.singleton_method_added(name)
    return if name == :method_added || name == __method__

    iv_name = "@__delfos_inherited_defined_#{self.name}"
    if name == :inherited && instance_variable_get(iv_name).nil?
      instance_variable_set(iv_name, true)
      original = method(name)

      define_singleton_method name do |*args, &block|
        parent = ancestors.select{|a| a.class == ::Class}[1]
        ::Delfos::Patching.notify_inheritance(parent, self)

        original.call(*args, &block)
      end
    else
      ::Delfos::Patching.perform(self, name, private_methods, class_method: true)
    end
  end
end
