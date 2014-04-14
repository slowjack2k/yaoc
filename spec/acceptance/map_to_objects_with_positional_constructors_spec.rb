require "spec_helper"

feature "Map objects to classes with positional constructors", %q{
   In order to map objects with positional constructors
   as a lib user
   I want to map object from an input object to an output object and reverse with a given mapping strategy
} do

  given(:mapper)do
    Yaoc::ObjectMapper.new(load_result_object_class, dump_result_object_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        reverse_fetcher :public_send

        strategy :to_array_mapping

        rule to: 0, from: :id,
             reverse_from: :id

        rule to: 1, from: :name,
             reverse_from: :name
      end
    end
  end

  given(:load_result_object_class) do
    Struct.new(:id, :name) do
      include Equalizer.new(:id, :name)
    end
  end

  given(:dump_result_object_class) do
    Yaoc::Helper::StructH(:id, :name) do
      include Equalizer.new(:id, :name)
    end
  end

  given(:input_object)do
    dump_result_object
  end

  given(:load_result_object)do
    load_result_object_class.new(1,"paul")
  end

  given(:dump_result_object)do
    dump_result_object_class.new({id: 1, name: "paul"})
  end

  scenario "creates an result object from an input_object" do
    expect(mapper.load(input_object)).to eq load_result_object
  end

  scenario "dumps an result object as result object" do
    expect(mapper.dump(load_result_object)).to eq dump_result_object
  end

end