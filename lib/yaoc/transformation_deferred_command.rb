module Yaoc
  class TransformationDeferredCommand < TransformationCommand

    def value(time_saved_to_convert)
      proc = ->{
        value_fetcher_proc.call(time_saved_to_convert, fetcher, from)
      }

      TransformationDeferredCommand.deferrer_strategy(proc)
    end

    def self.deferrer_strategy(proc)
      Yaoc::Helper::ToProcDelegator.new(proc)
    end

  end
end