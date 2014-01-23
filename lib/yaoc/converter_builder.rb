module Yaoc

  class ConverterBuilder
    attr_accessor  :build_commands, :command_order

    def initialize(command_order=:recorded_order, fetcher=:fetch)
      self.build_commands = []
      self.command_order = command_order
      self.fetcher = fetcher
    end

    def add_mapping(&block)
      instance_eval &block
      apply_commands!
    end

    def converter_class
      @converter_class ||= Struct.new(:to_convert, :fetcher) do
        include MappingBase
        include Strategies::ToHashMapping
      end
    end


    def rule(to: nil, from: to, converter: nil)
      build_commands.push  ->{ converter_class.map(to, from, converter) }
    end

    def apply_commands!
      reset_converters!

      build_commands_ordered.each &:call
    end

    def converter(fetch_able)
      converter_class.new(fetch_able, fetcher)
    end

    def fetcher=(new_fetcher)
      @fetcher= new_fetcher
    end

    protected

    def fetcher
      @fetcher ||= :fetch
    end

    def fetch_with(new_fetcher)
      self.fetcher = new_fetcher
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