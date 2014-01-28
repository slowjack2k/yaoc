require "spec_helper"

describe Yaoc::MappingBase do
  subject{
    Struct.new(:to_convert) do
      include Yaoc::MappingBase

      self.mapping_strategy = ->(obj){
        result = {}
        obj.converter_methods.map do |method_name|
          obj.public_send(method_name, obj.to_convert, result)
        end
      }

    end
  }

  describe "created module" do
    it "can be inspected" do
      subject.new_mapping(to: :foo, from: :bar)
      expect(subject.class_private_module.inspect).to include("map_0000_bar_to_foo")
    end
  end

  describe ".map" do

    it "creates a bunch of mapping methods" do
      subject.new_mapping(to: :foo, from: :bar)
      subject.new_mapping(to: :bar, from: :foo)

      expect(subject.new({bar: :my_to_convert, foo: :my_result}).call()).to eq [{:foo=>:my_to_convert, :bar=>:my_result},
                                                                                {:foo=>:my_to_convert, :bar=>:my_result}]
    end

    it "uses my converter when provided" do
      subject.new_mapping(to: :bar, from: :foo, converter: ->(*){})

      expect(subject.new(:my_to_convert).call()).to eq [nil]
    end

    it 'supports deferred mappings' do
      subject.new_mapping(to: :bar, from: :foo, lazy_loading: true)
      object_to_convert = {foo: [:my_result]}

      expect(object_to_convert).not_to receive :fetch

      subject.new(object_to_convert).call()
    end

    it "returns results for deferred mappings" do
      subject.new_mapping(to: :bar, from: :foo, lazy_loading: true)
      object_to_convert = double("object_to_convert")

      result = subject.new(object_to_convert).call()

      expect(object_to_convert).to receive(:fetch).with(:foo).and_return([:my_result])

      expect(result.first[:bar].first).to eq :my_result
    end
  end

  describe "#converter_methods" do
    it "preserves method order" do
      subject.new_mapping(to: 0, from: 1, converter: ->(*){})
      subject.new_mapping(to: 1, from: :a, converter: ->(*){})

      expect(subject.converter_methods).to eq [:map_0000_1_to_0, :map_0001_a_to_1]
    end
  end

  describe "#fetcher" do
    let(:subject_with_fetcher){
      Struct.new(:to_convert) do
        include Yaoc::MappingBase

        def fetcher
          "my_fetcher"
        end

      end
    }

    it "uses in class declared fetcher" do
      expect(subject_with_fetcher.new().fetcher).to eq "my_fetcher"
    end

    it "uses build in fetcher without a fetcher definition" do
      expect(subject.new().fetcher).to eq :fetch
    end

  end

  describe "#call" do
    let(:mapper){
      subject.new(:some_thing)
    }

    it "delegates execution to strategy" do
      expect(subject.mapping_strategy).to receive(:call).with mapper

      mapper.call
    end

    it "return nil when to_convert is nil" do
      mapper.to_convert = nil
      expect(mapper.call).to be_nil
    end

  end

  describe "#to_proc" do
    it "creates a wrapper around call" do
      mapper = subject.new()
      mapper_as_proc = mapper.to_proc
      expect(mapper).to receive :call

      mapper_as_proc.call(:some_thing)
    end

    it "changes 'to_convert' temporary" do
      mapper = subject.new(:old_some_thing)
      mapper_as_proc = mapper.to_proc

      expect(mapper).to receive(:to_convert=).ordered.with(:some_thing)
      expect(mapper).to receive(:to_convert=).ordered.with(:old_some_thing)

      mapper_as_proc.call(:some_thing)
    end

    it "changes 'to_convert' even when a exception occurs" do
      mapper = subject.new(:old_some_thing)
      mapper_as_proc = mapper.to_proc

      mapper.stub(:call) do
        raise "MyException"
      end

      expect(mapper).to receive(:to_convert=).ordered.with(:some_thing)
      expect(mapper).to receive(:to_convert=).ordered.with(:old_some_thing)

      expect{mapper_as_proc.call(:some_thing)}.to raise_error "MyException"
    end
  end

end