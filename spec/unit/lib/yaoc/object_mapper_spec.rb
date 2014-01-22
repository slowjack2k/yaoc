require "spec_helper"

describe Yaoc::ObjectMapper do
  subject{
    Yaoc::ObjectMapper.new(Struct.new(:id, :name)).tap{|mapper|
      mapper.stub(:converter_class).and_return(converter_class)
      mapper.stub(:reverse_converter_class).and_return(reverse_converter_class)
    }
  }

  let(:converter_class){
    double("converter_class", map: nil, new: converter)
  }

  let(:reverse_converter_class){
    double("reverse_converter_class", map: nil, new: reverse_converter)
  }

  let(:converter){
    double("converter", call: nil)
  }

  let(:reverse_converter){
    double("reverse_converter", call: nil)
  }

  describe "#add_mapping" do

    it "creates a mapper" do

      expect(converter_class).to receive(:map).with(:id, :id2, :some_proc)
      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc,
             reverse_converter: :some_reverse_proc
      end

    end

    it "creates a revers mapper" do

      expect(reverse_converter_class).to receive(:map).with(:id2, :id, :some_reverse_proc)

      subject.add_mapping do
        rule to: :id,
             from: :id2,
             converter: :some_proc,
             reverse_converter: :some_reverse_proc
      end

    end

    it "uses defaults" do
      expect(converter_class).to receive(:map).with(:id, :id, nil)
      expect(reverse_converter_class).to receive(:map).with(:id, :id, nil)

      subject.add_mapping do
        rule to: :id
      end

    end

    it "allows to set a fetcher" do
      subject.add_mapping do
        fetcher :public_send
        rule to: :id
      end

      expect(subject.send :fetcher_method).to eq(:public_send)
    end

    it "allows to set a reverse_fetcher" do
      subject.add_mapping do
        reverse_fetcher :fetch
        rule to: :id
      end

      expect(subject.send :reverse_fetcher_method).to eq(:fetch)
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