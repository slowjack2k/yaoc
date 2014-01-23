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
  end

  describe "#load" do
    it "creates an object of result_class kind" do
      data = {id: 1}

      converter.stub(call: data)

      expect(subject.load_result_source).to receive(:call).with(data)

      subject.load(data)
    end
  end

  describe "#dump" do

    it "dump the object as an wanted object" do
      data = {id: 1}

      reverse_converter.stub(call: data)

      expect(subject.dump_result_source).to receive(:call).with(data)

      subject.dump(data)
    end

  end

end