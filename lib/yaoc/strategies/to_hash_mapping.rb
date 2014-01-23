module Yaoc
  module Strategies
    module ToHashMapping
      def self.included(other)
        other.extend(ClassMethods)
      end

      def call
        converter_methods.reduce({}) do |result, method_name|
          self.public_send(method_name, to_convert, result)
        end
      end

      module ClassMethods

      end
    end
  end
end