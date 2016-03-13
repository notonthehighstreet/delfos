require_relative "patching"

class BasicObject
  def self.method_added(name)
    return if name == __method__

    ::Delfos::Patching.setup_method_call_logging(self, name, private_instance_methods, class_method: false)
  end

  def self.singleton_method_added(name)
    return if name == __method__

    ::Delfos::Patching.setup_method_call_logging(self, name, private_methods, class_method: true)
  end
end
