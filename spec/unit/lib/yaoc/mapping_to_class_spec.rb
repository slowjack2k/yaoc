require "spec_helper"

describe Yaoc::MappingToClass do
  subject{
    Struct.new(:target_source) do
      include Yaoc::MappingToClass

      self.mapping_strategy = ->(obj){
        [1]
      }

    end.new(expected_class)
  }

  let(:expected_class){
    Struct.new(:id)
  }

  describe "#call" do
    it "creates on object of the wanted kind" do
      expect(subject.call).to be_kind_of expected_class
    end

    it "can use a lambda for creation" do
      creator = ->(*args){}
      expect(creator).to receive :call
      subject.target_source = creator
      subject.call
    end


    it "splashes args when conversion result is an array" do
      creator = ->(*args){}
      subject.class.mapping_strategy = ->(obj){
        [1, 2]
      }

      expect(creator).to receive(:call).with(1,2)

      subject.target_source = creator

      subject.call
    end
  end

end