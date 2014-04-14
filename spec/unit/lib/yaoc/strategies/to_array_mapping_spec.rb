require "spec_helper"

describe Yaoc::Strategies::ToArrayMapping do
  subject do
    Struct.new(:to_convert) do
      include Yaoc::MappingBase
      self.mapping_strategy = Yaoc::Strategies::ToArrayMapping
    end
  end

  let(:mapper)do
    subject.new(source_object)
  end

  let(:source_object)do
    {id: 1, name: "paul"}
  end

  let(:expected_array)do
    [1, "paul"]
  end

  describe ".call" do

    it "creates a hash from a object" do
      subject.map(to: 0, from: :id)
      subject.map(to: 1, from: :name)

      expect(mapper.call).to eq(expected_array)
    end

    it "uses my converter proc" do
      subject.map(to: 0, from: :id)
      subject.map(to: 3, from: :fullname, converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, 3, "#{source.fetch(:name)} Hello World") })

      ext_expectation = expected_array.clone
      ext_expectation[3] = "#{ext_expectation[1]} Hello World"
      ext_expectation[1] = nil
      ext_expectation[2] = nil

      expect(mapper.call).to eq(ext_expectation)
    end

    context "changed fetcher method" do
      let(:source_object)do
        Struct.new(:id, :name).new(1, "paul")
      end

      it "uses custom fetcher methods" do
        subject.map(to: 0, from: :id)
        subject.map(to: 1, from: :name)

        def mapper.fetcher
          :public_send
        end

        expect(mapper.call).to eq(expected_array)
      end

      it "works with arrays" do
        subject.map(to: 1, from: 0)
        subject.map(to: 0, from: 1)

        def mapper.fetcher
          :[]
        end

        mapper.to_convert = [1, "paul"]

        expect(mapper.call).to eq(expected_array.reverse)
      end
    end

  end

end
