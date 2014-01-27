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
    subject{
      Struct.new(:target_source) do
        include Yaoc::MappingToClass

        self.mapping_strategy = ->(obj){
          {:name => :new_name}
        }

      end.new(expected_class)
    }

    it "creates on object of the wanted kind" do
      expect(subject.call).to be_kind_of expected_class
    end

    it "can use a lambda for creation" do
      creator = ->(*args){}
      expect(creator).to receive :call
      subject.target_source = creator
      subject.call
    end


    it "splattes args when conversion result is an array" do
      creator = ->(*args){}
      subject.class.mapping_strategy = ->(obj){
        [1, 2]
      }

      expect(creator).to receive(:call).with(1,2)

      subject.target_source = creator

      subject.call
    end

    it "fills an existing object instead of create a new one" do
      obj = Struct.new(:id, :name).new(:my_id)
      created_obj = subject.call(obj)

      expect(created_obj).to eq obj
      expect(obj.name).to eq :new_name
      expect(obj.id).to eq :my_id
    end
  end

  describe "#to_a" do
    it "satisfies Array(*) when included into structs" do
      expect(subject.to_a).to eq ([subject])
    end
  end


end