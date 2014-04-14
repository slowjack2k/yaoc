require 'spec_helper'

describe Yaoc::ManyToOneMapperChain do

  subject do
    Yaoc::ManyToOneMapperChain.new(first_mapper, second_mapper)
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
    it 'converts multiple input objects into one result object' do
      converted_user = subject.load_all([existing_old_user, existing_old_user])

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing object' do
      user = new_user_class.new

      converted_user = subject.load_all([existing_old_user, existing_old_user], user)

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to eq ['first_name', 'second_name']

      expect(converted_user.object_id).to eq user.object_id
    end
  end

  describe '#load_first' do
    it 'converts the first object into the result object' do
      converted_user = subject.load_first(existing_old_user)

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to be_nil
    end
  end

  describe '#load_next' do
    it 'converts the next object into the result object' do
      subject.load_first(existing_old_user)
      converted_user = subject.load_next(existing_old_user)

      expect(converted_user.id).to eq 'existing_user_2'
      expect(converted_user.names).to eq ["first_name", "second_name"]
    end

    it 'raises an exception when too many values are passed' do
      subject.load_first(existing_old_user)
      subject.load_next(existing_old_user)

      expect{subject.load_next(existing_old_user)}.to raise_error "ToManyInputObjects"
    end

  end

  describe '#dump_all' do
    it 'converts multiple input objects into one result object' do
      converted_user = subject.dump_all([existing_user, existing_user])

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to eq ['first_name', 'second_name']
    end

    it 'fills an existing object' do
      user = old_user_class.new
      converted_user = subject.dump_all([existing_user, existing_user], user)

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to eq ['first_name', 'second_name']

      expect(converted_user.object_id).to eq user.object_id
    end
  end


  describe '#dump_first' do
    it 'dumps the first object into the result object' do
      converted_user = subject.dump_first(existing_user)

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to be_nil
    end
  end

  describe '#dump_next' do
    it 'dumps the next object into the result object' do
      subject.dump_first(existing_user)
      converted_user = subject.dump_next(existing_user)

      expect(converted_user.o_id).to eq 'existing_user_2'
      expect(converted_user.o_names).to eq ['first_name', 'second_name']
    end
  end
end