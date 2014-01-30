module Yaoc
  module MappingBase

    def self.included(other)
      other.extend(ClassMethods)
      other.send(:include, TransformationCommands)
      other.extend(TransformationCommandsClassMethods)
    end

    def to_proc
      ->(to_convert){
        old_to_convert = self.to_convert
        begin
          self.to_convert = to_convert
          call
        ensure
          self.to_convert = old_to_convert
        end
      }
    end

    def call
      unless to_convert.nil?
        self.class.mapping_strategy.call(self)
      else
        nil
      end
    end

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
          method_implementation = converter || converter_proc(to, from, lazy_loading)

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

    module TransformationCommands
      def fill_result_with_value(result, key, value)
        result.tap{|taped_result| taped_result[key] = value}
      end

      def fill_result_from_proc(result, key, proc, deferred=false)
        value = if deferred
                  deferrer_strategy(proc)
                else
                  proc.call
                end

        fill_result_with_value(result, key, value)
      end

      def deferrer_strategy(proc)
        Yaoc::Helper::ToProcDelegator.new(proc)
      end
    end

    module TransformationCommandsClassMethods
      def converter_proc(to, from, deferred=false)
        # will be executed in mapper object instance context later through :define_method
        -> (to_convert, result){
          get_value_with = ->{
            to_convert.public_send(fetcher, from)
          }

          fill_result_from_proc(result, to, get_value_with, deferred)
        }
      end
    end

  end
end