module Yaoc
  module Strategies
    module ToArrayMapping
      def self.included(other)
        other.extend(ClassMethods)
      end

      def call
        [].tap do |result|
          converter_methods.each do |method_name|
            self.public_send(method_name, to_convert, result)
          end
        end
      end

      module ClassMethods

      end

    end
  end
end