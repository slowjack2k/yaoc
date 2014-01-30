require "spec_helper"

describe Yaoc::Strategies::ToHashMapping do
  subject{
    Struct.new(:to_convert) do
      include Yaoc::MappingBase
      self.mapping_strategy = Yaoc::Strategies::ToHashMapping
    end
  }

  let(:mapper){
    subject.new(source_object)
  }

  let(:source_object){
    {id: 1, name: "paul"}
  }

  let(:expected_hash){
    {id: 1, name: "paul"}
  }

  describe "#call" do

    it "creates a hash from a object" do
      subject.map(to: :id, from: :id)
      subject.map(to: :name, from: :name)

      expect(mapper.call).to eq(expected_hash)
    end

    it "renames attributes" do
      subject.map(to: :id)
      subject.map(to: :fullname, from: :name)

      renamed_expectation = expected_hash.clone
      renamed_expectation[:fullname] = renamed_expectation.delete :name

      expect(mapper.call).to eq(renamed_expectation)
    end

    it "uses my converter proc" do
      subject.map(to: :id)
      subject.map(to: :name, from: :fullname, converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :name, source.fetch(:name) + " Hello World") })

      ext_expectation = expected_hash.clone
      ext_expectation[:name] += " Hello World"

      expect(mapper.call).to eq(ext_expectation)
    end

    context "changed fetcher method" do
      let(:source_object){
        Struct.new(:id, :name).new(1, "paul")
      }

      it "uses custom fetcher methods" do
        subject.map(to: :id)
        subject.map(to: :name)

        def mapper.fetcher
          :public_send
        end

        expect(mapper.call).to eq(expected_hash)
      end

      it "works with arrays" do
        subject.map(to: :id, from: 0)
        subject.map(to: :name, from: 1)

        def mapper.fetcher
          :[]
        end

        mapper.to_convert = [1, "paul"]

        expect(mapper.call).to eq(expected_hash)
      end
    end

  end

end