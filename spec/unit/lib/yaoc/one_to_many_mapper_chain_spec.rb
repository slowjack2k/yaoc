require 'spec_helper'

describe Yaoc::OneToManyMapperChain do

  subject do
    Yaoc::OneToManyMapperChain.new(first_mapper, second_mapper)
  end

  let(:first_mapper)do
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        rule to: :id,
             from: :o_id
      end
    end
  end

  let(:second_mapper)do
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        rule to: :names,
             from: :o_names
      end
    end
  end

  let(:new_user_class)do
    Yaoc::Helper::StructHE(:id, :names)
  end

  let(:old_user_class)do
    Yaoc::Helper::StructHE(:o_id, :o_names)
  end

  let(:existing_old_user)do
    old_user_class.new(
        o_id: 'existing_user_2',
        o_names: ['first_name', 'second_name']
    )
  end

  let(:existing_user)do
    new_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  end

  describe '.new' do
    subject do
      Yaoc::ManyToOneMapperChain
    end

    it 'converts symbols into converter' do
      registry = double('registry')

      expect(registry).to receive(:for).with(:one)
      expect(registry).to receive(:for).with(:two)
      expect(registry).to receive(:for).with(:three)

      subject.stub(registry: registry)

      subject.new(:one, :two, :three)
    end
  end

  describe '#load_all' do
    it 'converts one input objects into multiple result object' do
      converted_users = subject.load_all(existing_old_user)

      expect(converted_users[0].id).to eq 'existing_user_2'
      expect(converted_users[1].names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing objects' do
      user1 = new_user_class.new
      user2 = new_user_class.new

      converted_users = subject.load_all(existing_old_user, [user1, user2])

      expect(converted_users[0].id).to eq 'existing_user_2'
      expect(converted_users[1].names).to eq ['first_name', 'second_name']

      expect(converted_users[0].object_id).to eq user1.object_id
      expect(converted_users[1].object_id).to eq user2.object_id
    end
  end

  describe '#dump_all' do
    it 'converts one input object into multiple result object' do
      converted_users = subject.dump_all(existing_user)

      expect(converted_users[0].o_id).to eq 'existing_user_2'
      expect(converted_users[1].o_names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing objects' do
      user1 = old_user_class.new
      user2 = old_user_class.new
      converted_users = subject.dump_all(existing_user, [user1, user2])

      expect(converted_users[0].o_id).to eq 'existing_user_2'
      expect(converted_users[1].o_names).to eq ['first_name', 'second_name']

      expect(converted_users[0].object_id).to eq user1.object_id
      expect(converted_users[1].object_id).to eq user2.object_id
    end
  end

end
