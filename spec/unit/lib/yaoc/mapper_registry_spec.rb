require 'spec_helper'

describe Yaoc::MapperRegistry do
  subject do
    Yaoc::MapperRegistry
  end

  describe '.add' do
    it "registers an object" do
      subject.add(:my_key, Object)
      expect(subject.for(:my_key)).to eq Object
    end
  end

  describe '.for' do
    it "returns the registered object" do
      subject.add(:my_key, Object)
      expect(subject.for(:my_key)).to eq Object
    end
  end

  describe '.scope_storage' do
    it 'supports the change of scope storage' do
      expect {subject.scope_storage(ScopedStorage::ThreadLocalStorage)}.not_to raise_error
    end

  end

end
