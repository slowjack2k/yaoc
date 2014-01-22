module Yaoc

  class ObjectMapper
    attr_accessor :result_class, :forward_commands, :backward_commads

    def initialize(result_class)
      self.result_class = result_class
      self.forward_commands = []
      self.backward_commads = []
    end

    def load(fetch_able)
      result_class.new(converter(fetch_able).call())
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
      reset_converters!

      forward_commands.each &:call
      backward_commads.each &:call
    end

    def reset_converters!
      @reverse_converter_class = nil
      @converter_class = nil
    end

    def rule(to: nil, from: to, converter: nil, reverse_converter: nil)
      forward_commands.push    ->{ converter_class.map(to, from, converter) }
      backward_commads.unshift ->{ reverse_converter_class.map(from, to, reverse_converter) }
    end

    def fetcher(new_fetcher)
      @fetcher= new_fetcher
    end

    def fetcher_method
      @fetcher ||= :fetch
    end

    def reverse_fetcher(new_fetcher)
      @reverse_fetcher = new_fetcher
    end

    def reverse_fetcher_method
      @reverse_fetcher ||= :public_send
    end

    def converter(fetch_able)
      converter_class.new(fetch_able, fetcher_method)
    end

    def converter_class
      @converter_class ||= new_converter_class
    end

    def reverse_converter(fetch_able)
      reverse_converter_class.new(fetch_able, reverse_fetcher_method)
    end

    def reverse_converter_class
      @reverse_converter_class ||= new_converter_class
    end

    def new_converter_class
      Struct.new(:to_convert, :fetcher) do
        include MappingBase
        include Strategies::ToHashMapping
      end
    end

  end
end