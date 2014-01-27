module Yaoc
  module Helper
    module StructHashConstructor
      def initialize(params={})
        super()

        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params
      end
    end
  end
end