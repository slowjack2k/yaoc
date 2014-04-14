require "spec_helper"

describe Yaoc::ConverterBuilder do
  subject do
    ot = other_converter
    is_col = is_collection

    Yaoc::ConverterBuilder.new.tap do|converter|
      converter.add_mapping do
        fetch_with :[]
        rule to: :id,
             from: :name,
             is_collection: is_col,
             object_converter: ot
      end
    end

  end

  let(:other_converter)do
    Class.new do
      def to_proc
        @proc ||= ->(index, *args)do
          [nil, nil, :my_result_1, nil,  :my_result_2][index]
        end
      end

      def to_a
        [self]
      end

    end.new
  end

  let(:is_collection)do
    false
  end

  describe "#converter_to_proc" do

    it "creates a converter proc" do
      expect(other_converter.to_proc).to receive(:call).with(2).and_return(:my_result)
      expect(subject.converter(nil, nil).map_0000_name_to_id({ name: 2 },{})).to eq(id: :my_result)
    end

    context "value to convert is a collection" do
      let(:is_collection)do
        true
      end

      it "creates a converter proc for collections" do
        expect(subject.converter(nil, nil).map_0000_name_to_id({ name: [2, 4] },{})).to eq(id: [:my_result_1, :my_result_2])
      end

    end
  end

end
