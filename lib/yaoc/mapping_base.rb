module Yaoc
  module MappingBase
    def self.included(other)
      other.extend(ClassMethods)
    end

    def to_proc
      ->(to_convert)do
        old_to_convert = self.to_convert
        begin
          self.to_convert = to_convert
          call
        ensure
          self.to_convert = old_to_convert
        end
      end
    end

    def call
      unless to_convert.nil?
        self.class.mapping_strategy.call(self)
      else
        nil
      end
    end
    alias_method :to_hash_or_array, :call

    def converter_methods
      self.class.converter_methods
    end

    def fetcher
      defined?(super) ? super : :fetch
    end

    module ClassMethods
      def mapping_strategy=(new_strat)
        @mapping_strategy = new_strat
      end

      def mapping_strategy
        @mapping_strategy
      end

      def map(to: nil, from: to, converter: nil, lazy_loading: false)
        class_private_module(:Mapping).tap do |mod|
          method_implementation = TransformationCommand.create(to: to, from: from, deferred: lazy_loading, conversion_proc: converter)

          mod.send :define_method, "map_#{"%04d" %[converter_methods.count]}_#{from}_to_#{to}".to_sym, method_implementation
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