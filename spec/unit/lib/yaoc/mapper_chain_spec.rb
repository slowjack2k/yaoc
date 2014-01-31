require 'spec_helper'

describe Yaoc::MapperChain do

  subject{
    Yaoc::MapperChain.new(first_mapper, second_mapper)
  }

  let(:first_mapper){
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        rule to: :id,
             from: :o_id
      end
    end
  }

  let(:second_mapper){
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        rule to: :names,
             from: :o_names
      end
    end
  }

  let(:new_user_class){
    Yaoc::Helper::StructHE(:id, :names)
  }

  let(:old_user_class){
    Yaoc::Helper::StructHE(:o_id, :o_names)
  }

  let(:existing_old_user){
    old_user_class.new(
        o_id: 'existing_user_2',
        o_names: ['first_name', 'second_name']
    )
  }

  let(:existing_user){
    new_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  }

  describe '#load' do
    it 'converts multiple input objects into one result object' do
      converted_user = subject.load([existing_old_user, existing_old_user])

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing object' do
      user = new_user_class.new

      converted_user = subject.load([existing_old_user, existing_old_user], user)

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to eq ['first_name', 'second_name']

      expect(converted_user.object_id).to eq user.object_id
    end
  end

  describe '#dump' do
    it 'converts multiple input objects into one result object' do
      converted_user = subject.dump([existing_user, existing_user])

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing object' do
      user = old_user_class.new
      converted_user = subject.dump([existing_user, existing_user], user)

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to eq ['first_name', 'second_name']

      expect(converted_user.object_id).to eq user.object_id
    end
  end
end