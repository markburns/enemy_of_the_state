require "set"

module EnemyOfTheState
  class << self
    def display
      each_class_instance_variable { |s| puts(s) }
      nil
    end

    def fail
      each_class_instance_variable { |s| Kernel.fail(s) }

      nil
    end

    private

    def each_class_instance_variable(&block)
      set = Set.new

      application_objects do |o|
        next if o == set

        begin
          next if set.include?(o) 
        rescue 
          # exception whilst iterating over set means we are 
          # looking inside this `set' instance itself
          next
        end

        set.add(o)


        variables_for(o, count=0, &block)
      end
    end

    def application_objects
      ObjectSpace.each_object do |o|
        klass = o.is_a?(Module) ? o : o.class;

        next if ignore?(klass)
        yield klass
      end
    end

    def ignore?(klass)
      return true unless klass

      methods =
        klass.methods.map{|m|          klass.method(m)} +
        klass.instance_methods.map{|m| klass.instance_method(m) }

      methods.all? do |m|
        Delfos::MethodLogging.exclude?(m)
      end
    end

    def variables_for(namespace, count, &block)
      return unless namespace.is_a?(Module)

      display_variables(namespace, &block)

      namespace.constants.each do |c|
        klass = relevant_constant_for(c, namespace)
        next unless klass

        display_variables(klass, &block)

        handle_nesting(klass, namespace, count, &block)
      end
    end

    def handle_nesting(klass, namespace, count, &block)
      klass.constants.each do |k|
        k = klass.const_get(k)
        next if k == klass || k == namespace

        count += 1
        variables_for(k, count, &block)
      end
    end

    def relevant_constant_for(c, namespace)
      return if namespace == c
      klass = namespace.const_get(c)

      return unless klass.is_a?(Module)
      return unless klass.name
      return unless namespace.name
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
