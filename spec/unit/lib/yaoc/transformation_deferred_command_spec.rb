require 'spec_helper'

describe Yaoc::TransformationDeferredCommand do
  subject{
    Yaoc::TransformationDeferredCommand.new(to: :id, from: :name, fetch_method: :fetch)
  }

  let(:source){
    {name: 'my_name'}
  }

  let(:result){
    {}
  }

  describe '#value' do
    let(:value_fetcher) { double('value fetcher proc')}

    it 'deferres access to source object' do
      expect(source).not_to receive :fetch

      subject.value(source)
    end

    it 'access to source object, when data is needed' do
      expect(source).to receive :fetch

      subject.value(source).to_s
    end

  end
end