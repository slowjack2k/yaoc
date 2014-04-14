require 'spec_helper'

describe Yaoc::Helper::StructHashConstructor do
  subject do
    Yaoc::Helper::StructH(:id, :name).new(id: 1, name: 'no name')
  end

  it 'creates a struct with a hash enabled constructor' do
    expect(subject.id).to eq 1
    expect(subject.name).to eq 'no name'
  end

  context 'with equal support' do
    subject do
      Yaoc::Helper::StructHE(:id, :name)
    end

    it 'returns true when all attributes are equal' do
      first = subject.new(id: 1, name: 'no name')
      second = subject.new(id: 1, name: 'no name')

      expect(first).to eq second
    end

    it 'returns false when not all atributes are equal' do
      first = subject.new(id: 1, name: 'no name')
      second = subject.new(id: 1, name: 'no name2')

      expect(first).not_to eq second
    end
  end

end
