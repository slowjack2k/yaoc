module Yaoc
  class TransformationDeferredCommand < TransformationCommand
    def value(time_saved_to_convert)
      proc = ->do
        value_fetcher_proc.call(time_saved_to_convert, fetcher, from)
      end

      TransformationDeferredCommand.deferrer_strategy(proc)
    end

    def self.deferrer_strategy(proc)
      Yaoc::Helper::ToProcDelegator.new(proc)
    end
  end
end
