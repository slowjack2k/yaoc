require "spec_helper"

describe Yaoc::ConverterBuilder do
  subject do
    Yaoc::ConverterBuilder.new().tap do|converter|
      converter.stub(:converter_class).and_return(converter_class)
    end
  end


  let(:converter_class)do
    double("converter_class", map: nil, new: converter)
  end

  let(:converter)do
    double("converter", call: nil)
  end

  let(:default_map_args)do
    {
        to: :id,
        from: :id,
        converter: nil,
        lazy_loading: false
    }
  end

  describe "#command_order" do

    it "applies command in recorded order as default" do
      subject.command_order = :recorded_order

      expected_args_first = default_map_args.clone
      expected_args_second = default_map_args.clone

      expected_args_second[:to] = expected_args_second[:from] = :name

      expect(converter_class).to receive(:map).ordered.with(expected_args_first)
      expect(converter_class).to receive(:map).ordered.with(expected_args_second)

      subject.add_mapping do
        rule to: :id
        rule to: :name
      end

    end

    it "applies command in reverse recorded order when wanted" do
      subject.command_order = :reverse_order

      expected_args_first = default_map_args.clone.merge(to: :name, from: :name)
      expected_args_second = default_map_args.clone

      expect(converter_class).to receive(:map).ordered.with(expected_args_first)
      expect(converter_class).to receive(:map).ordered.with(expected_args_second)

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
      expect(converter_class).to receive(:map).with(to: :id, from: :id2, converter: :some_proc, lazy_loading: false)

      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc
      end

    end

    it "uses defaults" do
      expect(converter_class).to receive(:map).with(default_map_args)

      subject.add_mapping do
        rule to: :id
      end

    end

    it "allows to use array of attributes" do
      expected_args_first = default_map_args.clone
      expected_args_second = default_map_args.clone.merge(to: :name, from: :name)

      expect(converter_class).to receive(:map).ordered.with(expected_args_first)
      expect(converter_class).to receive(:map).ordered.with(expected_args_second)

      subject.add_mapping do
        rule to: [:id, :name]
      end
    end

    it "use the right 'to' when 'from' in arrays is missing" do
      expected_args_first = default_map_args.clone.merge(from: :r_id)
      expected_args_second = default_map_args.clone.merge(to: :name, from: :name)


      expect(converter_class).to receive(:map).ordered.with(expected_args_first)
      expect(converter_class).to receive(:map).ordered.with(expected_args_second)

      subject.add_mapping do
        rule to: [:id, :name],
             from: [:r_id]
      end
    end

    it "supports the use of a object converter" do
      expect(converter_class).to receive(:map).ordered.with(to: :id, from: :id, converter: kind_of(Proc), lazy_loading: false)
      other_converter = :some_converter

      subject.add_mapping do
        rule to: :id,
             object_converter: other_converter
      end

    end

    it "supports the collection flag for object converters" do
      expected_args = default_map_args.clone.merge(converter: kind_of(Proc))

      expect(converter_class).to receive(:map).ordered.with(expected_args)
      other_converter = :some_converter

      subject.add_mapping do
        rule to: :id,
             is_collection: true,
             object_converter: other_converter
      end

    end

    it "supports lazy loading" do
      expected_args = default_map_args.clone.merge(lazy_loading: true)

      expect(converter_class).to receive(:map).ordered.with(expected_args)

      subject.add_mapping do
        rule to: :id,
             lazy_loading: true
      end
    end

    it "supports a do nothing" do
      expected_args = default_map_args.clone.merge(converter: kind_of(Proc))

      expect(converter_class).to receive(:map).ordered.with(expected_args)

      subject.add_mapping do
        rule to: :id,
             converter: noop
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

  describe "#noop" do
    it "returns the input" do
      expect(subject.noop.call(:some_thing, :expected_value)).to eq :expected_value
    end
  end

end