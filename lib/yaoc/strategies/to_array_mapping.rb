module Yaoc
  module Strategies
    module ToArrayMapping
      def self.call(conv_object)
        [].tap do |result|
          conv_object.converter_methods.each do |method_name|
            conv_object.public_send(method_name, conv_object.to_convert, result)
          end
        end
      end
    end
  end
end