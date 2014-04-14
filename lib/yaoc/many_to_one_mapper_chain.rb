module Yaoc
  class ManyToOneMapperChain
    attr_accessor :converter, :last_result, :next_result

    def self.registry
      Yaoc::MapperRegistry
    end

    def initialize(*converter)
      self.converter = converter
    end

    def load_first(input_object, object_to_fill = nil)
      converter_iterator.rewind
      self.next_result = converter_iterator.next.load(input_object, object_to_fill)
    end

    def load_next(input_object)
      self.next_result = converter_iterator.next.load(input_object, self.next_result)
    rescue StopIteration
      raise "ToManyInputObjects"
    end

    def load_all(input_objects, object_to_fill = nil)
      each_object_with_converter(input_objects) do |converter, input_object|
        object_to_fill = converter.load(input_object, object_to_fill)
      end

      self.last_result = object_to_fill
    end

    def dump_first(input_object, object_to_fill = nil)
      converter_iterator.rewind
      self.next_result = converter_iterator.next.dump(input_object, object_to_fill)
    end

    def dump_next(input_object)
      self.next_result = converter_iterator.next.dump(input_object, self.next_result)
    end

    def dump_all(input_objects, object_to_fill = nil)
      each_object_with_converter(input_objects) do |converter, input_object|
        object_to_fill = converter.dump(input_object, object_to_fill)
      end

      self.last_result = object_to_fill
    end

    protected

    def converter=(new_converter)
      @converter = new_converter.map { |converter| converter.is_a?(Symbol) ? ManyToOneMapperChain.registry.for(converter) : converter }
    end

    def converter_iterator
      @converter_iterator ||= self.converter.each
    end

    def each_object_with_converter(input_objects)
      it_input_objects = input_objects.each
      it_converters = self.converter.each

      loop do
        begin
          converter = it_converters.next
          input_object = it_input_objects.next

          yield converter, input_object

        rescue StopIteration
          break
        end
      end
    end
  end
end
