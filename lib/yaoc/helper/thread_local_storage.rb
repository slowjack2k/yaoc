module Yaoc
  module Helper
    class ThreadLocalStorage
      class << self
        private :new
      end

      attr_accessor :data

      def self.for(scope_name="default")
        Thread.current["_#{name}_#{scope_name}"] ||= new
      end

      def initialize
        self.data||={}
      end
    end
  end
end

