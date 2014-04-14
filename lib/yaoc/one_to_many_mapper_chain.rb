module Yaoc
  class OneToManyMapperChain
    attr_accessor :converter, :last_result, :next_result

    def self.registry
      Yaoc::MapperRegistry
    end

    def initialize(*converter)
      self.converter = converter
    end

    def load_all(input_object, objects_to_fill=[])
      objects_to_fill = Array(objects_to_fill)
      results = []

      each_object_with_converter(objects_to_fill) do |converter, object_to_fill|
        results << converter.load(input_object, object_to_fill)
      end

      self.last_result = results
    end

    def dump_all(input_object, objects_to_fill=nil)
      objects_to_fill = Array(objects_to_fill)
      results = []

      each_object_with_converter(objects_to_fill) do |converter, object_to_fill|
        results << converter.dump(input_object, object_to_fill)
      end

      self.last_result = results
    end

    protected

    def converter=(new_converter)
      @converter = new_converter.map{|converter| converter.is_a?(Symbol) ? OneToManyMapperChain.registry.for(converter) : converter}
    end

    def each_object_with_converter(objects_to_fill)
      converter.each_with_index do |converter, index|
        object_to_fill = objects_to_fill[index]

        yield converter, object_to_fill
      end
    end
  end
end