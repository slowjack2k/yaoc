module Yaoc
  class TransformationCommand

    protected
    attr_accessor :to, :from, :fetcher , :proc, :value_fetcher_proc

    public

    def self.create(to, from, deferred=false, proc=nil, fetcher_proc=nil)
      # will be executed in mapper object instance context later through :define_method
      tc_source = deferred ? TransformationDeferredCommand : TransformationCommand

      -> (to_convert, result){
        tc_source.new(to, from, fetcher, proc, fetcher_proc).call(to_convert, result)
      }
    end

    def self.fill_result_with_value(result, key, value)
      result.tap{|taped_result| taped_result[key] = value}
    end

    def initialize(to, from, fetcher, proc=nil, fetcher_proc=nil)
      self.to = to
      self.from = from
      self.proc = proc
      self.fetcher = fetcher
      self.value_fetcher_proc = fetcher_proc || ->(to_convert, fetcher, from){ to_convert.public_send(fetcher, from)}
    end

    def call(to_convert, result)

      unless proc.nil?
        instance_exec(to_convert, result, &proc)
      else
        TransformationCommand.fill_result_with_value(result, to, value(to_convert))
      end

    end

    def value(to_convert)
      value_fetcher_proc.call(to_convert, fetcher, from)
    end

  end
end