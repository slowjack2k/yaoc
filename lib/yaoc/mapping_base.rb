module Yaoc
  module MappingBase
    include AbstractType


    def self.included(other)
      other.extend(ClassMethods)
    end

    abstract_method :call
    abstract_method :fill_result_with_value


    def converter_methods
      self.class.converter_methods
    end

    def fetcher
      defined?(super) ? super : :fetch
    end

    module ClassMethods
      include AbstractType

      abstract_method :converter_proc

      def map(to, from, block=nil)
        class_private_module(:Mapping).tap do |mod|
          mod.send :define_method, "map_#{"%04d" %[converter_methods.count]}_#{from}_to_#{to}".to_sym, (block || converter_proc(to, from))
          include mod
        end
      end

      def converter_methods
        class_private_module(:Mapping).instance_methods(false).sort
      end

      # inspired by Avdi Grimm, rubytapas.com 028-macros-and-modules
      def class_private_module(name=:Mapping)

        if const_defined?(name, false)
          const_get(name)
        else
          new_mod = Module.new do
            def self.to_s
              "Mapping (#{instance_methods(false).join(', ')})"
            end

            def self.inspect
              to_s
            end
          end
          const_set(name, new_mod)
        end
      end

    end
  end
end