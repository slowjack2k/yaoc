require 'spec_helper'

describe Yaoc::Helper::ToProcDelegator do
  subject{
    Yaoc::Helper::ToProcDelegator.new(lazy_proc)
  }

  let(:lazy_proc){
    ->{
      [:some_value]
    }
  }

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

  describe '#nil?' do
    it "returns true when delegate value is nil" do
      subject = Yaoc::Helper::ToProcDelegator.new(->{nil})
      expect(subject).to be_nil
    end

    it "returns false when delegate value is not nil" do
      expect(subject).not_to be_nil
    end
  end

end