require 'delegate'

module Yaoc
  module Helper
    class ToProcDelegator < SimpleDelegator
      attr_accessor :_initialisation_proc, :_initialisation_proc_loaded

      def initialize(_initialisation_proc)
        super(nil).tap do
          self._initialisation_proc = _initialisation_proc
          self._initialisation_proc_loaded = false
        end
      end

      def __getobj__
        unless self._initialisation_proc_loaded
          self._initialisation_proc_loaded = true
          __setobj__(self._initialisation_proc.call)
        end

        super
      end

      def class
        __getobj__.class
      end

      def kind_of?(some_class)
        super || __getobj__.kind_of?(some_class)
      end

      def nil?
        __getobj__.nil?
      end

      def _initialisation_proc_loaded?
        self._initialisation_proc_loaded
      end

      def _needs_conversion?
        _initialisation_proc_loaded? && ! nil?
      end
    end
  end
end
