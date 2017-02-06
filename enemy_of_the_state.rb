require "set"
require_relative "application_folders"
require_relative "common_path"

module EnemyOfTheState
  class << self
    def display
      each_class_instance_variable { |s| puts(s) }
    end

    def fail
      each_class_instance_variable { |s| Kernel.fail(s) }
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

        #next if ignore?(klass)
        yield klass
      end
    end

    def ignore?(klass)
      return true unless klass

      methods =
        klass.methods.map{|m|          klass.method(m)} +
        klass.instance_methods.map{|m| klass.instance_method(m) }

      methods.all? do |m|
        EnemyOfTheState::ApplicationFolders.exclude?(m)
      end
    end

    def variables_for(namespace, count, &block)
      return if ignore?(namespace)
      return unless namespace.is_a?(Module)

      namespace.instance_variables.each do |iv|
        val = namespace.instance_eval(iv.to_s)

        unless val.nil?
          yield "non-nil class variable found:\n  #{namespace} #{iv}: #{val.inspect}"
        end
      end
    end
  end
end
