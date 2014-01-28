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

  let(:expected_default_params){
    {
        to: :id,
        from: :id,
        converter: nil,
        object_converter: [],
        is_collection: nil,
        lazy_loading: nil,
    }
  }

  describe "#add_mapping" do

    it "creates a converter" do
      expected_params = expected_default_params

      expect(converter_builder).to receive(:rule).with(expected_params)

      subject.add_mapping do
        rule to: :id
      end

    end

    it "creates a revers converter" do
      expected_params = expected_default_params

      expect(reverse_converter_builder).to receive(:rule).with(expected_params)

      subject.add_mapping do
        rule to: :id
      end

    end

  end

  describe "#rule" do

    it "allows to use another converter as converter" do
      converter_double = double("converter")

      expected_params = expected_default_params.merge(
          object_converter: [converter_double],
      )

      expected_params_reverse = expected_default_params.merge(
          object_converter: [converter_double]
      )


      expect(converter_builder).to receive(:rule).with(expected_params)
      expect(reverse_converter_builder).to receive(:rule).with(expected_params_reverse)

      expect(converter_double).to receive(:converter).and_return(converter_double)
      expect(converter_double).to receive(:reverse_converter).and_return(converter_double)


      subject.add_mapping do
        rule to: :id,
             object_converter: converter_double
      end
    end

    it "accepts a reverse mapping for from and to" do
      expected_params = expected_default_params.merge(
          to: :id_r,
          from: :id_r,
      )

      expect(reverse_converter_builder).to receive(:rule).with(expected_params)

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

    it "allows to set lazy_loading" do
      expected_params = expected_default_params.merge(
          lazy_loading: true,
      )

      expect(converter_builder).to receive(:rule).with(expected_params)
      expect(reverse_converter_builder).to receive(:rule).with(expected_params)

      subject.add_mapping do
        rule to: :id,
             lazy_loading: true
      end
    end

    it "allows to set reverse lazy_loading" do
      expected_params = expected_default_params.merge(
          lazy_loading: nil,
      )

      expected_params_reverse = expected_default_params.merge(
          lazy_loading: true,
      )

      expect(converter_builder).to receive(:rule).with(expected_params)
      expect(reverse_converter_builder).to receive(:rule).with(expected_params_reverse)

      subject.add_mapping do
        rule to: :id,
             reverse_lazy_loading: true
      end
    end


  end

  describe "#load" do
    it "creates an object of result class kind" do
      expect(converter).to receive(:call)

      subject.load({})
    end

    it "uses an existing object for the result" do
      preloaded_obj = Object.new

      expect(converter).to receive(:call).with(preloaded_obj)

      subject.load({}, preloaded_obj)
    end
  end

  describe "#dump" do

    it "dump the object as an wanted object" do
      expect(reverse_converter).to receive(:call)

      subject.dump({})
    end

    it "uses an existing object for the result" do
      preloaded_obj = Object.new

      expect(reverse_converter).to receive(:call).with(preloaded_obj)

      subject.dump({}, preloaded_obj)
    end

  end

end