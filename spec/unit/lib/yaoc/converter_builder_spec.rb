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

  describe "#command_order" do

    it "applies command in recorded order as default" do
      subject.command_order = :recorded_order

      expect(converter_class).to receive(:map).ordered.with(:id, :id, nil)
      expect(converter_class).to receive(:map).ordered.with(:name, :name, nil)

      subject.add_mapping do
        rule to: :id
        rule to: :name
      end

    end

    it "applies command in reverse recorded order when wanted" do
      subject.command_order = :reverse_order

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
      expect(subject).to receive(:rule).with(to: :id, from: :from, converter: :converter)

      subject.add_mapping do
        fetch_with  :public_send
        with_strategy :to_array_mapping
        rule to: :id, from: :from, converter: :converter
      end

      expect(subject.send :fetcher).to eq(:public_send)
      expect(subject.strategy).to eq(:to_array_mapping)
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

    it "use the right 'to' when 'from' in arrays is missing" do
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
      subject.add_mapping do
        with_strategy :to_array_mapping
      end

      expect(subject.send(:converter_class).mapping_strategy).to eq(Yaoc::Strategies::ToArrayMapping)
    end

    it "raises an exception when not all commands are applied" do
      subject = Yaoc::ConverterBuilder.new()
      subject.strategy = :to_array_mapping

      expect{subject.converter({})}.to raise_exception
    end
  end
end