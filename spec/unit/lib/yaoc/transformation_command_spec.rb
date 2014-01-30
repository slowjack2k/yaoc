require 'spec_helper'

describe Yaoc::TransformationCommand do
  subject{
    Yaoc::TransformationCommand.new(to: :id, from: :name, fetch_method: :fetch)
  }

  let(:source){
    {name: 'my_name'}
  }

  let(:result){
    {}
  }

  describe '.create' do
    subject{
      Yaoc::TransformationCommand
    }

    it 'creates a proc' do
      expect(subject.create(to: :to, from: :from)).to respond_to :call
    end

    it 'uses default_source when deferred is flase' do
      expect(subject).to receive :default_source
      subject.create(to: :to, from: :from)
    end

    it 'uses default_source when deferred is flase' do
      expect(subject).to receive :deferred_source
      subject.create(to: :to, from: :from, deferred: true)
    end

  end

  describe '#call' do

    it 'transfers data from source to result' do
      subject.call(source, result)
      expect(result[:id]).to eq source[:name]
    end

    it 'add the fetched value to result' do
      new_result = subject.call(source, result)
      expect(new_result).to eq result
    end

    it 'returns a result' do
      new_result = subject.call(source, result)
      expect(new_result).to eq result
    end

  end

  describe '#value' do
    subject {
      Yaoc::TransformationCommand.new(to: :id, from: :name, fetch_method: :fetch, fetcher_proc: value_fetcher)
    }

    let(:value_fetcher) { double('value fetcher proc')}

    it 'uses a given proc for value fetching' do
      expect(value_fetcher).to receive(:call).with(source, :fetch, :name).and_return(:some_thing_to_store)

      expect(subject.value(source)).to eq :some_thing_to_store
    end

  end
end