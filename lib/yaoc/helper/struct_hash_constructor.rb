module Yaoc
  module Helper
    module StructHashConstructor
      def self.included(klass)
        klass.send :prepend, Initializer
      end

      module Initializer
        def initialize(params={})
          super()

          params.each do |attr, value|
            self.public_send("#{attr}=", value)
          end if params
        end
      end
    end

    module_function
    def StructH(*args, &block)
      Struct.new(*args, &block).tap do|new_class|
        new_class.send(:include, Yaoc::Helper::StructHashConstructor)
      end
    end

  end
end