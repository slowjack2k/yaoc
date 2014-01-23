module Yaoc

  class ObjectMapper
    attr_accessor :load_result_source, :dump_result_source

    def initialize(load_result_source, dump_result_source=nil)
      self.load_result_source = load_result_source
      self.dump_result_source = dump_result_source
    end

    def load(fetch_able)
      converter(fetch_able).call()
    end

    def dump(object)
      reverse_converter(object).call()
    end

    def add_mapping(&block)
      instance_eval &block
      apply_commands
    end

    protected

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
      converter_builder.converter(fetch_able, load_result_source)
    end

    def reverse_converter(fetch_able)
      reverse_converter_builder.converter(fetch_able, dump_result_source)
    end

    def converter_builder
      @converter_builder ||= Yaoc::ConverterBuilder.new()
    end

    def reverse_converter_builder
      @reverse_converter_builder ||= Yaoc::ConverterBuilder.new(:reverse_order, :public_send)
    end

  end
end