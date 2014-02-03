require 'spec_helper'

feature 'Map multiple one object to many', %q{
   In order to convert objects in lesser steps
   as a lib user
   I want to be able to chain converters and get multiple objects out of one
} do

  given(:mapper_chain){
    Yaoc::OneToManyMapperChain.new(first_mapper, second_mapper)
  }

  given!(:first_mapper){
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        register_as :first_mapper
        fetcher :public_send
        rule to: :id
      end
    end
  }

  given!(:second_mapper){
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        register_as :second_mapper
        fetcher :public_send
        rule to: :names
      end
    end
  }

  given(:new_user_class){
    Yaoc::Helper::StructHE(:id, :names)
  }

  given(:old_user_class){
    Yaoc::Helper::StructHE(:id, :names)
  }

  given(:existing_old_user){
    old_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  }

  given(:existing_user){
    new_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  }

  scenario 'loads multiple result object from one input object' do
    converted_users = mapper_chain.load_all(existing_old_user)

    expect(converted_users[0].id).to eq 'existing_user_2'
    expect(converted_users[1].names).to eq ['first_name', 'second_name']
  end

  scenario 'dumps multiple result object from one input object' do
    converted_users = mapper_chain.dump_all(existing_user)

    expect(converted_users[0].id).to eq 'existing_user_2'
    expect(converted_users[1].names).to eq ['first_name', 'second_name']
  end

  scenario 'symbols as converter' do
    mapper_chain = Yaoc::ManyToOneMapperChain.new(:first_mapper, :second_mapper)

    converted_user = mapper_chain.load_all([existing_old_user, existing_old_user])

    expect(converted_user.id).to eq 'existing_user_2'
    expect(converted_user.names).to eq ['first_name', 'second_name']
  end

end