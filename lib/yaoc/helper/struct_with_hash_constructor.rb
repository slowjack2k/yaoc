module Yaoc
  module Helper

    class StructWithHashConstructor < Struct
      def new(*)
        super.tap do |new_class|
          new_class.send(:include, Yaoc::Helper::StructHashConstructor)
        end
      end
    end

    module_function
    def StructH(*args)
      StructWithHashConstructor.new(*args)
    end
  end
end