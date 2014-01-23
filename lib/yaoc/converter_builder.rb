module Yaoc

  class ConverterBuilder
    attr_accessor  :build_commands, :command_order, :strategy, :all_commands_applied

    def initialize(command_order=:recorded_order, fetcher=:fetch)
      self.build_commands = []
      self.command_order = command_order
      self.fetcher = fetcher
      self.strategy = :to_hash_mapping
      self.all_commands_applied = false
    end

    def add_mapping(&block)
      instance_eval &block
      apply_commands!
    end

    def rule(to: nil, from: to, converter: nil)
      self.all_commands_applied = false

      to_s = Array(to)
      from_s = Array(from)
      converter_s = Array(converter)

      to_s.each_with_index do |to, index|
        build_commands.push  ->{ converter_class.map(to, from_s[index] || to, converter_s[index]) }
      end
    end

    def apply_commands!
      reset_converters!
      self.all_commands_applied = true

      build_commands_ordered.each &:call
    end

    def converter(fetch_able)
      raise "BuildCommandsNotExecuted" unless self.all_commands_applied?
      converter_class.new(fetch_able, fetcher)
    end

    def fetcher=(new_fetcher)
      @fetcher= new_fetcher
    end

    protected

    def converter_class
      @converter_class ||= Struct.new(:to_convert, :fetcher) do
        include MappingBase
      end.tap do |new_class|
        new_class.send(:include, strategy_module)
      end
    end

    def strategy_module
      Yaoc::Strategies.const_get sym_as_module_name(strategy)
    end

    def sym_as_module_name(sym)
      sym.to_s
         .split("_")
         .map(&:capitalize)
         .join()
         .to_sym
    end

    def all_commands_applied?
      all_commands_applied
    end

    def fetcher
      @fetcher ||= :fetch
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

    def reset_converters!
      @converter_class = nil
    end

  end

end