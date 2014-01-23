require "spec_helper"

describe Yaoc::ObjectMapper do
  subject{
    Yaoc::ObjectMapper.new(Struct.new(:id, :name)).tap{|mapper|
      mapper.stub(:converter_builder).and_return(converter_builder)
      mapper.stub(:reverse_converter_builder).and_return(reverse_converter_builder)
    }
  }

  let(:converter_builder){
    double("converter_builder", rule: nil, apply_commands!: nil, converter: converter)
  }

  let(:reverse_converter_builder){
    double("reverse_converter_builder", rule: nil, apply_commands!: nil, converter: reverse_converter)
  }

  let(:converter){
    double("converter", call: nil)
  }

  let(:reverse_converter){
    double("reverse_converter", call: nil)
  }

  describe "#add_mapping" do

    it "creates a converter" do

      expect(converter_builder).to receive(:rule).with(to: :id, from: :id2, converter: :some_proc)

      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc,
             reverse_converter: :some_reverse_proc
      end

    end

    it "creates a revers converter" do

      expect(reverse_converter_builder).to receive(:rule).with(to: :id2, from: :id, converter: :some_reverse_proc)

      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc,
             reverse_converter: :some_reverse_proc
      end

    end

    it "uses defaults" do
      expect(converter_builder).to receive(:rule).with(to: :id, from: :id, converter: nil)
      expect(reverse_converter_builder).to receive(:rule).with(to: :id, from: :id, converter: nil)

      subject.add_mapping do
        rule to: :id
      end

    end

    it "accepts a reverse mapping for from and to" do
      expect(reverse_converter_builder).to receive(:rule).with(to: :id_r, from: :id_r, converter: nil)

      subject.add_mapping do
        rule to: :id, reverse_to: :id_r, reverse_from: :id_r
      end
    end

    it "allows to set a fetcher" do
      expect(converter_builder).to receive(:fetcher=).with(:public_send)

      subject.add_mapping do
        fetcher :public_send
        rule to: :id
      end


    end

    it "allows to set a reverse_fetcher" do
      expect(reverse_converter_builder).to receive(:fetcher=).with(:fetch)

      subject.add_mapping do
        reverse_fetcher :fetch
        rule to: :id
      end
    end

    it "allows to change the strategy" do
      expect(converter_builder).to receive(:strategy=).with(:to_array_mapping)

      subject.add_mapping do
        strategy :to_array_mapping
        rule to: 0, from: :id
      end
    end

    it "allows to change the reverse strategy" do
      expect(reverse_converter_builder).to receive(:strategy=).with(:to_array_mapping)

      subject.add_mapping do
        reverse_strategy :to_array_mapping
        rule to: :id, from: 0
      end
    end
  end

  describe "#load" do
    it "creates an object of result class kind" do
      expect(converter).to receive(:call)

      subject.load({})
    end
  end

  describe "#dump" do

    it "dump the object as an wanted object" do
      expect(reverse_converter).to receive(:call)

      subject.dump({})
    end

  end

end