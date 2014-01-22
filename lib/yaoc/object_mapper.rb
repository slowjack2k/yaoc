module Yaoc

  class ObjectMapper
    attr_accessor :result_class

    def initialize(result_class)
      self.result_class = result_class
    end

    def load(fetch_able)
      call = converter(fetch_able).call()

      result_class.new(call)
    end

    def dump(object)
      reverse_converter(object).call()
    end

    def add_mapping(&block)
      instance_eval &block
    end

    protected

    def rule(to: nil, from: to, converter: nil, reverse_converter: nil)
      converter_class.map(to, from, converter)
      reverse_converter_class.map(from, to, reverse_converter)
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