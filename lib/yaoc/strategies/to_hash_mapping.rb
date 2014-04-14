module Yaoc
  module Strategies
    module ToHashMapping
      def self.call(conv_object)
        conv_object.converter_methods.reduce({}) do |result, method_name|
          conv_object.public_send(method_name, conv_object.to_convert, result)
        end
      end
    end
  end
end