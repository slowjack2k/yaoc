require 'spec_helper'

describe Yaoc::Helper::ToProcDelegator do
  subject do
    Yaoc::Helper::ToProcDelegator.new(lazy_proc)
  end

  let(:lazy_proc)do
    ->do
      [:some_value]
    end
  end

  it 'evaluates a proc not with initialisation' do
    expect(lazy_proc).not_to receive :call
    Yaoc::Helper::ToProcDelegator.new(lazy_proc)
  end

  it 'evaluates a proc when methods are delegated' do
    expect(lazy_proc).to receive(:call)
    subject.respond_to? :some_method_name
  end

  it 'delegates to the proc result' do
    expect(subject.first).to eq :some_value
  end

  describe '#kind_of?' do

    it 'returns true when class is "real class"' do
      expect(subject).to be_kind_of Yaoc::Helper::ToProcDelegator
    end

    it 'returns true when class is delegated class' do
      expect(subject).to be_kind_of lazy_proc.call.class
    end

    it 'returns false for other classes' do
      expect(subject).not_to be_kind_of String
    end

  end

  describe '#class' do
    it 'is the lazy loaded object class' do
      expect(subject.class).to eq Array
    end
  end

  describe '#nil?' do
    it "returns true when delegate value is nil" do
      subject = Yaoc::Helper::ToProcDelegator.new(-> { nil })
      expect(subject).to be_nil
    end

    it "returns false when delegate value is not nil" do
      expect(subject).not_to be_nil
    end
  end

  describe '#_initialisation_proc_loaded?' do
    it "returns true, when __getobj__ was accessed" do
      expect(subject._initialisation_proc_loaded?).to be_falsy
      subject.__getobj__
      expect(subject._initialisation_proc_loaded?).to be_truthy
    end
  end

  describe '_needs_conversion?' do
    it 'returns true when the object was loaded and __getobj__ is not nil' do
      subject.__getobj__
      expect(subject._needs_conversion?).to be_truthy
    end

    it 'returns false when the object was not' do
      expect(subject._needs_conversion?).to be_falsy
    end

    it 'returns false when the object was loaded but is nil' do
      subject.__getobj__
      subject.__setobj__(nil)
      expect(subject._needs_conversion?).to be_falsy
    end
  end

end
