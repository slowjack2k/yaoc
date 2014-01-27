require "spec_helper"

feature "Map objects to classes with positional constructors", %q{
   In order to map objects with positional constructors
   as a lib user
   I want to map object from an input object to an output object and reverse with a given mapping strategy
} do

  given(:mapper){
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
  }

  given(:load_result_object_class) {
    Struct.new(:id, :name) do
      include Equalizer.new(:id, :name)
    end
  }

  given(:dump_result_object_class) {
    Yaoc::Helper::StructH(:id, :name) do
      include Equalizer.new(:id, :name)
    end
  }

  given(:input_object){
    dump_result_object
  }

  given(:load_result_object){
    load_result_object_class.new(1,"paul")
  }

  given(:dump_result_object){
    dump_result_object_class.new({id: 1, name: "paul"})
  }

  scenario "creates an result object from an input_object" do
    expect(mapper.load(input_object)).to eq load_result_object
  end

  scenario "dumps an result object as result object" do
    expect(mapper.dump(load_result_object)).to eq dump_result_object
  end

end