require 'spec_helper'

describe Yaoc::Helper::Scope do
  class DummyStorage
    def initialize(new_data)
      @data = new_data
    end

    def for(*args)
      self
    end

    def data
      @data
    end

  end

  subject{
    Yaoc::Helper::Scope.new("default", DummyStorage.new(data_double))
  }

  let(:data_double){
    {}
  }

  describe '#[]=' do
    it 'let me set values' do
      subject['new_value'] = 123
      expect(subject.fetch('new_value')).to eq 123
    end
  end

  describe '#[]' do
    it 'let me fetch values' do
      subject['new_value'] = 123
      expect(subject['new_value']).to eq 123
    end
  end

  describe '#clear!' do
    it 'let me fetch values' do
      subject['new_value'] = 123
      subject.clear!
      expect(subject['new_value']).to be_nil
    end
  end

  describe '#fetch' do
    it 'works like hash fetch' do
      fetched_value = subject.fetch('some_key'){|*args| args}

      expect(fetched_value).to eq ['some_key']
    end
  end

end