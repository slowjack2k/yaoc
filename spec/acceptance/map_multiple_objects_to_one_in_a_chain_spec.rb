require 'spec_helper'

feature 'Map multiple objects to one', %q{
   In order to convert objects in lesser steps
   as a lib user
   I want to be able to chain converters and input objects
} do

  given(:mapper_chain)do
    Yaoc::ManyToOneMapperChain.new(first_mapper, second_mapper)
  end

  given!(:first_mapper)do
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        register_as :first_mapper
        fetcher :public_send
        rule to: :id
      end
    end
  end

  given!(:second_mapper)do
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        register_as :second_mapper
        fetcher :public_send
        rule to: :names
      end
    end
  end

  given(:new_user_class)do
    Yaoc::Helper::StructHE(:id, :names)
  end

  given(:old_user_class)do
    Yaoc::Helper::StructHE(:id, :names)
  end

  given(:existing_old_user)do
    old_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  end

  given(:existing_user)do
    new_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  end

  scenario 'loads an result object from multiple input object' do
    converted_user = mapper_chain.load_all([existing_old_user, existing_old_user])

    expect(converted_user.id).to eq 'existing_user_2'
    expect(converted_user.names).to eq ['first_name', 'second_name']
  end

  scenario 'dumps an result object from multiple input object' do
    converted_user = mapper_chain.dump_all([existing_user, existing_user])

    expect(converted_user.id).to eq 'existing_user_2'
    expect(converted_user.names).to eq ['first_name', 'second_name']
  end

  scenario 'symbols as converter' do
    mapper_chain = Yaoc::ManyToOneMapperChain.new(:first_mapper, :second_mapper)

    converted_user = mapper_chain.load_all([existing_old_user, existing_old_user])

    expect(converted_user.id).to eq 'existing_user_2'
    expect(converted_user.names).to eq ['first_name', 'second_name']
  end

end