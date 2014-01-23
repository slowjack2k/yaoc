require "spec_helper"

describe Yaoc::ConverterBuilder do
  subject{
    Yaoc::ConverterBuilder.new().tap{|converter|
      converter.stub(:converter_class).and_return(converter_class)
    }
  }


  let(:converter_class){
    double("converter_class", map: nil, new: converter)
  }

  let(:converter){
    double("converter", call: nil)
  }

  describe ".new" do
    it "applies command in recorded order as default" do

      expect(converter_class).to receive(:map).ordered.with(:id, :id, nil)
      expect(converter_class).to receive(:map).ordered.with(:name, :name, nil)

      subject.add_mapping do
        rule to: :id
        rule to: :name
      end

    end

    it "applies command in reverse recorded order when wanted" do
      subject = Yaoc::ConverterBuilder.new(:reverse_order).tap{|converter|
        converter.stub(:converter_class).and_return(converter_class)
      }


      expect(converter_class).to receive(:map).ordered.with(:name, :name, nil)
      expect(converter_class).to receive(:map).ordered.with(:id, :id, nil)

      subject.add_mapping do
        rule to: :id
        rule to: :name
      end

    end
  end

  describe "#add_mapping" do

    it "delegates to internal methods" do
      expect(subject).to receive(:fetch_with).with(:public_send)
      expect(subject).to receive(:rule).with(to: :id, from: :from, converter: :converter)
      expect(subject).to receive(:with_strategy).with(:to_array_mapping)

      subject.add_mapping do
        fetch_with  :public_send
        with_strategy :to_array_mapping
        rule to: :id, from: :from, converter: :converter
      end
    end

  end

  describe "#rule" do
    it "creates a converter" do

      expect(converter_class).to receive(:map).with(:id, :id2, :some_proc)

      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc
      end

    end

    it "uses defaults" do
      expect(converter_class).to receive(:map).with(:id, :id, nil)

      subject.add_mapping do
        rule to: :id
      end

    end

    it "allows to use array of attributes" do
      expect(converter_class).to receive(:map).ordered.with(:id, :id, nil)
      expect(converter_class).to receive(:map).ordered.with(:name, :name, nil)

      subject.add_mapping do
        rule to: [:id, :name]
      end
    end

    it "use the right to when from in arrays is missing" do
      expect(converter_class).to receive(:map).ordered.with(:id, :r_id, nil)
      expect(converter_class).to receive(:map).ordered.with(:name, :name, nil)

      subject.add_mapping do
        rule to: [:id, :name],
             from: [:r_id]
      end
    end
  end

  describe "#converter" do
    it "creates a new converter class with the wanted strategy" do
      subject = Yaoc::ConverterBuilder.new()
      subject.strategy = :to_array_mapping

      expect(subject.converter({})).to be_kind_of Yaoc::Strategies::ToArrayMapping
    end
  end
end