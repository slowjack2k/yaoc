module Yaoc
  module MappingToClass

    def self.included(other)
      other.send(:include, MappingBase)
      other.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def call(*args)
        create_target(super)
      end

      def source_method
        self.target_source.respond_to?(:call) ? :call : :new
      end

      def create_target(args)
        if args.is_a? Array
          self.target_source.send(source_method, *args)
        else
          self.target_source.send(source_method, args)
        end
      end

      def to_a # wenn included into struct's Array(...) call's to_a
        [self]
      end
    end

  end
end