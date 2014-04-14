module Yaoc
  class NormalizedParameters
    attr_accessor :to_s, :from_s, :converter_s, :lazy_loading_s

    def initialize(to, from, converter, object_converter, is_collection, lazy_loading)
      self.to_s = Array(to)
      self.from_s = Array(from)
      self.converter_s = Array(converter)
      self.lazy_loading_s = Array(lazy_loading)

      object_converter_s = Array(object_converter)
      is_collection_s = Array(is_collection)

      self.to_s.each_with_index do |to, index|
        from_s[index] ||= to
        lazy_loading_s[index] ||= false
      end

      object_converter_s.each_with_index do |object_converter, index|
        converter_s[index] = converter_to_proc(to_s[index],
                                               from_s[index],
                                               object_converter,
                                               !!is_collection_s[index],
                                               !!lazy_loading_s[index])
      end
    end

    def each
      return to_enum(__callee__) unless block_given?

      self.to_s.each_with_index do |to, index|
        yield to, from_s[index] , converter_s[index], lazy_loading_s[index]
      end
    end

    def converter_to_proc(to, from, converter, is_collection, deferred)
      get_value_with = ->(source, fetcher, from)do
        object_to_convert = source.public_send(fetcher, from)

        if is_collection
          object_to_convert.map(&converter)
        else
          converter_as_proc = converter.to_proc
          converter_as_proc.call(object_to_convert)
        end
      end

      TransformationCommand.create(to: to, from: from, deferred: deferred, fetcher_proc: get_value_with)
    end
  end

  module BuilderDSLMethods
    def add_mapping(&block)
      instance_eval &block
      apply_commands!
    end

    def rule(to: nil, from: to, converter: nil, object_converter: nil, is_collection: nil, lazy_loading: nil)
      self.all_commands_applied = false

      NormalizedParameters.new(to, from, converter, object_converter, is_collection, lazy_loading).each do |to, from, converter, lazy_loading|
        build_commands.push  -> { converter_class.map(to: to, from: from , converter: converter, lazy_loading: lazy_loading) }
      end
    end

    def fetch_with(new_fetcher)
      self.fetcher = new_fetcher
    end

    def with_strategy(new_strategy)
      self.strategy = new_strategy
    end

    def build_commands_ordered
      if command_order == :recorded_order
        build_commands
      else
        build_commands.reverse
      end
    end

    def noop
      ->(_, result) { result }
    end
  end

  class ConverterBuilder
    include BuilderDSLMethods

    attr_accessor  :build_commands, :command_order,
                   :strategy, :all_commands_applied

    def initialize(command_order = :recorded_order, fetcher = :fetch)
      self.build_commands = []
      self.command_order = command_order
      self.fetcher = fetcher
      self.strategy = :to_hash_mapping
      self.all_commands_applied = false
    end

    def apply_commands!
      reset_converters!
      self.all_commands_applied = true

      build_commands_ordered.each &:call
    end

    def converter(fetch_able, target_source = nil)
      raise "BuildCommandsNotExecuted" unless self.all_commands_applied?
      converter_class.new(fetch_able, fetcher, target_source || ->(attrs) { attrs })
    end

    def fetcher=(new_fetcher)
      @fetcher = new_fetcher
    end

    protected

    def converter_class
      @converter_class ||= Struct.new(:to_convert, :fetcher, :target_source) do
        include MappingToClass

      end.tap do |new_class|
        new_class.mapping_strategy = strategy_module
      end
    end

    def strategy_module
      Yaoc::Strategies.const_get sym_as_module_name(strategy)
    end

    def sym_as_module_name(sym)
      sym.to_s
         .split("_")
         .map(&:capitalize)
         .join
         .to_sym
    end

    def all_commands_applied?
      all_commands_applied
    end

    def fetcher
      @fetcher ||= :fetch
    end

    def reset_converters!
      @converter_class = nil
    end
  end
end
