module Yaoc
  module MappingToClass
    def self.included(other)
      other.send(:include, MappingBase)
      other.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def call(pre_created_object = nil)
        source_converted_to_hash_or_array = to_hash_or_array
        unless source_converted_to_hash_or_array.nil?
          if pre_created_object.nil?
            create_target_from_class(source_converted_to_hash_or_array)
          else
            fill_target_object(source_converted_to_hash_or_array, pre_created_object)
          end
        else
          pre_created_object
        end
      end
      alias_method :to_object, :call

      def source_method
        target_source.respond_to?(:call) ? :call : :new
      end

      def create_target_from_class(args)
        array_based_constructor = args.is_a? Array

        if array_based_constructor
          target_source.send(source_method, *args)
        else
          target_source.send(source_method, args)
        end
      end

      def fill_target_object(attribute_hash, pre_created_object)
        fail 'UnexpectedStrategy' unless attribute_hash.respond_to? :each_pair

        attribute_hash.each_pair do |key, value|
          pre_created_object.send("#{key}=", value)
        end

        pre_created_object
      end

      def to_a # wenn included into struct's Array(...) call's to_a
        [self]
      end
    end
  end
end
