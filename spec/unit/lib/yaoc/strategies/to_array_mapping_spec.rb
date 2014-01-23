require "spec_helper"

describe Yaoc::Strategies::ToArrayMapping do
  subject{
    Struct.new(:to_convert) do
      include Yaoc::MappingBase
      self.mapping_strategy = Yaoc::Strategies::ToArrayMapping
    end
  }

  let(:mapper){
    subject.new(source_object)
  }

  let(:source_object){
    {id: 1, name: "paul"}
  }

  let(:expected_array){
    [1, "paul"]
  }

  describe ".call" do

    it "creates a hash from a object" do
      subject.map(0, :id)
      subject.map(1, :name)

      expect(mapper.call).to eq(expected_array)
    end


    it "uses my converter proc" do
      subject.map(0, :id)
      subject.map(3, :fullname, ->(source, result){ fill_result_with_value(result, 3, "#{source.fetch(:name)} Hello World") })

      ext_expectation = expected_array.clone
      ext_expectation[3] = "#{ext_expectation[1]} Hello World"
      ext_expectation[1] = nil
      ext_expectation[2] = nil

      expect(mapper.call).to eq(ext_expectation)
    end

    context "changed fetcher method" do
      let(:source_object){
        Struct.new(:id, :name).new(1, "paul")
      }

      it "uses custom fetcher methods" do
        subject.map(0, :id)
        subject.map(1, :name)

        def mapper.fetcher
          :public_send
        end

        expect(mapper.call).to eq(expected_array)
      end

      it "works with arrays" do
        subject.map(1, 0)
        subject.map(0, 1)

        def mapper.fetcher
          :[]
        end

        mapper.to_convert = [1, "paul"]

        expect(mapper.call).to eq(expected_array.reverse)
      end
    end

  end

end