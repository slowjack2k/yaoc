require 'spec_helper'

describe Yaoc::MapperRegistry do
  subject{
    Yaoc::MapperRegistry
  }

  describe '#add' do
    it "registers an object" do
      subject.add(:my_key, Object)
      expect(subject.for(:my_key)).to eq Object
    end
  end

  describe '#for' do
    it "returns the registered object" do
      subject.add(:my_key, Object)
      expect(subject.for(:my_key)).to eq Object
    end
  end
end