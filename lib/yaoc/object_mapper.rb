module Yaoc
  module MapperDSLMethods
    def add_mapping(&block)
      instance_eval &block
      apply_commands!
    end

    def rule(to: nil,
        from: to,
        converter: nil,
        reverse_to: from,
        reverse_from: to,
        reverse_converter: nil,
        object_converter: nil,
        reverse_object_converter: object_converter,
        is_collection: nil,
        lazy_loading: nil,
        reverse_lazy_loading: lazy_loading)

      object_converter = Array(object_converter).map{|converter| converter.is_a?(Symbol) ? registry.for(converter) : converter}
      reverse_object_converter = Array(reverse_object_converter).map{|converter| converter.is_a?(Symbol) ? registry.for(converter) : converter}

      converter_builder.rule(
          to: to,
          from: from,
          converter: converter,
          object_converter: object_converter.map(&:converter),
          is_collection: is_collection,
          lazy_loading: lazy_loading
      )

      reverse_converter_builder.rule(
          to: reverse_to,
          from: reverse_from,
          converter: reverse_converter,
          object_converter: reverse_object_converter.map(&:reverse_converter),
          is_collection: is_collection,
          lazy_loading: reverse_lazy_loading
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

    def noop
      ->(_, result){ result }
    end

    def register_as(name)
      registry.add(name, self) unless name.nil?
    end
  end

  class ObjectMapper
    include MapperDSLMethods

    attr_accessor :load_result_source, :dump_result_source, :registry

    def initialize(load_result_source, dump_result_source=nil, registry=Yaoc::MapperRegistry)
      self.load_result_source = load_result_source
      self.dump_result_source = dump_result_source
      self.registry = registry
    end

    def load(fetch_able, object_to_fill=nil)
      converter(fetch_able).call(object_to_fill)
    end

    def dump(object, object_to_fill=nil)
      reverse_converter(object).call(object_to_fill)
    end

    def converter(fetch_able=nil)
      converter_builder.converter(fetch_able, load_result_source)
    end

    def reverse_converter(fetch_able=nil)
      reverse_converter_builder.converter(fetch_able, dump_result_source)
    end

    def to_s
      "#{dump_result_source_name} <=> #{load_result_source_name}"
    end

    protected

    def dump_result_source_name
      dump_result_source.respond_to?(:name) ?  dump_result_source.name : dump_result_source.to_s
    end

    def load_result_source_name
      load_result_source.respond_to?(:name) ? load_result_source.name : load_result_source.to_s
    end

    def apply_commands!
      converter_builder.apply_commands!
      reverse_converter_builder.apply_commands!
    end

    def converter_builder
      @converter_builder ||= Yaoc::ConverterBuilder.new()
    end

    def reverse_converter_builder
      @reverse_converter_builder ||= Yaoc::ConverterBuilder.new(:reverse_order, :public_send)
    end
  end
end