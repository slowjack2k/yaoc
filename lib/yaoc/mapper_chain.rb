module Yaoc
  class MapperChain
    attr_accessor :converter

    def initialize(*converter)
      self.converter = converter
    end

    def load(input_objects, object_to_fill=nil)

      each_object_with_converter(input_objects) do |converter, input_object|
        object_to_fill = converter.load(input_object, object_to_fill)
      end

      object_to_fill
    end

    def dump(input_objects, object_to_fill=nil)

      each_object_with_converter(input_objects) do |converter, input_object|
        object_to_fill = converter.dump(input_object, object_to_fill)
      end

      object_to_fill
    end

    protected

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