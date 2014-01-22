require "spec_helper"

feature "Map objects", %q{
   In order to map object
   as a lib user
   I want to map object from an input object to an output object and reverse
} do

  given(:mapper){
    Yaoc::ObjectMapper.new(result_object_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :[]
        reverse_fetcher :public_send
        rule to: :name,
             converter: ->(source, result){ result.merge({name:  "#{source[:name]} Hello World"}) },
             reverse_converter: ->(source, result){ result.merge({name: source.name}) }
        rule to: :role, from: :fullrolename
        rule to: :id
      end
    end
  }

  given(:result_object_class) {
    Struct.new(:id, :name, :role) do
      include Equalizer.new(:id, :name, :role)

      def initialize(params={})
        super()

        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params
      end

    end
  }

  given(:input_hash){
    {id: 1, name: "paul", fullrolename: "admin"}
  }

  given(:result_object){
    result_object_class.new({id: 1, name: "paul", role: "admin"})
  }

  scenario "creates an result object from an input_object" do
    result_object.name += " Hello World"

    expect(mapper.load(input_hash)).to eq result_object
  end

  scenario "dumps an result object as hash" do
    expect(mapper.dump(result_object)).to eq input_hash
  end

end