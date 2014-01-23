require "spec_helper"

feature "Map objects", %q{
   In order to map object
   as a lib user
   I want to map object from an input object to an output object and reverse
} do

  given(:mapper){
    Yaoc::ObjectMapper.new(load_result_object_class, dump_result_object_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        reverse_fetcher :public_send
        rule to: :name,
             converter: ->(source, result){ result.merge({name:  "#{source[:name]} Hello World"}) },
             reverse_converter: ->(source, result){ result.merge({name: source.name}) }
        rule to: :role, from: :fullrolename
        rule to: :id
        rule to: [:foo, :bar]
      end
    end
  }

  given(:load_result_object_class) {
    Struct.new(:id, :name, :role, :foo, :bar) do
      include Equalizer.new(:id, :name, :role, :foo, :bar)

      def initialize(params={})
        super()

        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params
      end

    end
  }

  given(:dump_result_object_class) {
    Struct.new(:id, :name, :fullrolename, :foo, :bar) do
      include Equalizer.new(:id, :name, :fullrolename, :foo, :bar)

      def initialize(params={})
        super()

        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params
      end

    end
  }

  given(:input_hash){
    dump_result_object
  }

  given(:load_result_object){
    load_result_object_class.new({id: 1, name: "paul", role: "admin", foo: "some thing", bar: "some other thing"})
  }

  given(:dump_result_object){
    dump_result_object_class.new({id: 1, name: "paul", fullrolename: "admin", foo: "some thing", bar: "some other thing"})
  }

  scenario "creates an result object from an input_object" do
    load_result_object.name += " Hello World"

    expect(mapper.load(input_hash)).to eq load_result_object
  end

  scenario "dumps an result object as result object" do
    expect(mapper.dump(load_result_object)).to eq dump_result_object
  end

end