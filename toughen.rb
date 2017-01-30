gem "delfos"
require "delfos/method_logging"
Delfos.application_directories = ["./app", "./lib"]

module Toughen
  class << self
    def display_class_instance_variables
      ObjectSpace.each_object do |o|
        klass = puts o.is_a?(Module) ? o : o.class;

        next if ignore?(klass)

        show_variables_for(klass)

        break
      end
    end

    private

    def ignore?(klass)
      return true unless klass

      methods =
        klass.methods.map{|m|          klass.method(m)} +
        klass.instance_methods.map{|m| klass.instance_methods}

      methods.all? do
        Delfos::MethodLogging.exclude?(m)
      end
    end
  end

  def variables_for(n)
    return unless n.is_a?(Module)

    display_variables(n)

    n.constants.each do |c|
      klass = relevant_constant_for(c, n)
      next unless klass

      display_variables(klass)

      handle_nesting(klass, n)
    end
  end

  def handle_nesting(klass, n)
    klass.constants.each do |k|
      k = klass.const_get(k)
      next if k == klass || k == n

      variables_for(k)
    end
  end

  def relevant_constant_for(c, namespace)
    return if namespace == c
    klass = namespace.const_get(c)

    return unless klass.is_a?(Module)
    return unless klass.name[namespace.name]
    klass
  end

  def display_variables(klass)
    return unless klass.instance_variables.length.positive?

    klass.instance_variables.each do |iv|
      val = klass.instance_eval(iv.to_s)

      unless val.nil?
        puts "non-nil class variable found:\n  #{klass} #{iv}: #{val.inspect}"
      end
    end
  end
end
