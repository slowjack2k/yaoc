require 'spec_helper'

feature 'Map objects', %q{
   In order to map object
   as a lib user
   I want to map object from an input object to an output object and reverse
} do

  given(:mapper)do
    Yaoc::ObjectMapper.new(load_result_object_class, dump_result_object_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        reverse_fetcher :public_send
        rule to: :name,
             converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, :name, "#{source[:name]} Hello World") },
             reverse_converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, :name, source.name) }
        rule to: :role, from: :fullrolename
        rule to: :id
        rule to: [:foo, :bar]
      end
    end
  end

  given(:load_result_object_class) do
    Yaoc::Helper::StructHE(:id, :name, :role, :foo, :bar)
  end

  given(:dump_result_object_class) do
    Yaoc::Helper::StructHE(:id, :name, :fullrolename, :foo, :bar)
  end

  given(:input_object)do
    dump_result_object
  end

  given(:load_result_object)do
    load_result_object_class.new(id: 1, name: 'paul', role: 'admin', foo: 'some thing', bar: 'some other thing')
  end

  given(:dump_result_object)do
    dump_result_object_class.new(id: 1, name: 'paul', fullrolename: 'admin', foo: 'some thing', bar: 'some other thing')
  end

  scenario 'creates an result object from an input_object' do
    load_result_object.name += ' Hello World'

    expect(mapper.load(input_object)).to eq load_result_object
  end

  scenario 'dumps an result object as result object' do
    expect(mapper.dump(load_result_object)).to eq dump_result_object
  end

end
