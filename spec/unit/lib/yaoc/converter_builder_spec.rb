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

    it "allows to set a fetcher" do
      subject.add_mapping do
        fetch_with  :public_send
        rule to: :id
      end

      expect(subject.send :fetcher).to eq(:public_send)
    end

  end
end