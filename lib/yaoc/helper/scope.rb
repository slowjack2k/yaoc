module Yaoc
  module Helper
    class Scope

      attr_accessor :scope_name, :storage_source

      def initialize(scope_name="default", storage_source=ThreadGlobalStorage)
        self.scope_name  = scope_name
        self.storage_source = storage_source
      end

      def storage
        storage_source.for(scope_name)
      end

      def []=(key, value)
        self.storage[key]=value
      end

      def [](key)
        self.storage[key]
      end

      def clear!
        self.storage.clear
      end

      def fetch(*args, &block)
        self.storage.fetch(*args, &block)
      end

    end
  end
end