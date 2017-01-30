gem "delfos"
require "delfos/method_logging"
Delfos.application_directories = ["./app", "./lib"]

module Toughen
  class << self
    def display_class_instance_variables
      each_class_instance_variable { |s| puts(s) }
    end

    def fail_if_class_instance_variable
      each_class_instance_variable { |s| fail(s) }
    end

    private

    def each_class_instance_variable(&block)
      application_objects.each do |o|
        variables_for(o, &block)
      end
    end

    def application_objects
      ObjectSpace.each_object do |o|
        klass = puts o.is_a?(Module) ? o : o.class;

        next if ignore?(klass)
        yield klass
      end.uniq
    end

    def ignore?(klass)
      return true unless klass

      methods =
        klass.methods.map{|m|          klass.method(m)} +
        klass.instance_methods.map{|m| klass.instance_methods}

      methods.all? do
        Delfos::MethodLogging.exclude?(m)
      end
    end

    def variables_for(n, &block)
      return unless n.is_a?(Module)

      display_variables(n, &block)

      n.constants.each do |c|
        klass = relevant_constant_for(c, n)
        next unless klass

        display_variables(klass, &block)

        handle_nesting(klass, n, &block)
      end
    end

    def handle_nesting(klass, n, &block)
      klass.constants.each do |k|
        k = klass.const_get(k)
        next if k == klass || k == n

        variables_for(k, &block)
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
          yield "non-nil class variable found:\n  #{klass} #{iv}: #{val.inspect}"
        end
      end
    end
  end
end

