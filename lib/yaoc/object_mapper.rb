module Yaoc

  class ObjectMapper
    attr_accessor :load_result_source, :dump_result_source

    def initialize(load_result_source, dump_result_source=->(attrs){ attrs})
      self.load_result_source = load_result_source.respond_to?(:call) ? load_result_source : ->(*attrs){load_result_source.new(*attrs)}
      self.dump_result_source = dump_result_source.respond_to?(:call) ? dump_result_source : ->(*attrs){dump_result_source.new(*attrs)}
    end

    def load(fetch_able)
      converter_result = converter(fetch_able).call()
      call_constructor(load_result_source, converter_result)
    end

    def dump(object)
      converter_result = reverse_converter(object).call()
      call_constructor(dump_result_source, converter_result)
    end

    def add_mapping(&block)
      instance_eval &block
      apply_commands
    end

    protected

    def call_constructor(call_able, args)
      if args.is_a? Array
        call_able.call(*args)
      else
        call_able.call(args)
      end
    end

    def apply_commands
      converter_builder.apply_commands!
      reverse_converter_builder.apply_commands!
    end

    def rule(to: nil, from: to, converter: nil,
             reverse_to: from, reverse_from: to, reverse_converter: nil)

      converter_builder.rule(
          to: to,
          from: from,
          converter: converter,
      )

      reverse_converter_builder.rule(
          to: reverse_to,
          from: reverse_from,
          converter: reverse_converter,
      )
    end

    def fetcher(new_fetcher)
      converter_builder.fetcher = new_fetcher
    end

    def reverse_fetcher(new_fetcher)
      reverse_converter_builder.fetcher = new_fetcher
    end

    def strategy(new_strategy)
      converter_builder.strategy = new_strategy
    end

    def reverse_strategy(new_strategy)
      reverse_converter_builder.strategy = new_strategy
    end

    def converter(fetch_able)
      converter_builder.converter(fetch_able)
    end

    def reverse_converter(fetch_able)
      reverse_converter_builder.converter(fetch_able)
    end

    def converter_builder
      @converter_builder ||= Yaoc::ConverterBuilder.new()
    end

    def reverse_converter_builder
      @reverse_converter_builder ||= Yaoc::ConverterBuilder.new(:reverse_order, :public_send)
    end

  end
end