module Yaoc
  module Helper
    require 'thread'

    class ThreadGlobalStorage
      class << self
        private :new
      end

      attr_accessor :data

      @mutex = Mutex.new

      def self.mutex
        @mutex
      end

      def self.for(scope_name="default")
        mutex.synchronize {
          @storage ||= {}
          @storage[scope_name] ||= new
        }
      end

      def initialize
        self.data||={}
      end

      def []=(key, value)
        mutex.synchronize {
          self.data[key]=value
        }
      end

      def [](key)
        self.data[key]
      end

      def clear!
        mutex.synchronize {
          self.data.clear
        }
      end

      def fetch(*args, &block)
        self.data.fetch(*args, &block)
      end

      def mutex
        self.class.mutex
      end
      
    end
  end
end

