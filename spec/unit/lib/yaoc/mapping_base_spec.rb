require 'spec_helper'

describe Yaoc::MappingBase do
  subject do
    Struct.new(:to_convert) do
      include Yaoc::MappingBase

      self.mapping_strategy = ->(obj){
        result = {}
        obj.converter_methods.map do |method_name|
          obj.public_send(method_name, obj.to_convert, result)
        end
      }

    end
  end

  describe 'created module' do
    it 'can be inspected' do
      subject.map(to: :foo, from: :bar)
      expect(subject.class_private_module.inspect).to include('map_0000_bar_to_foo')
    end
  end

  describe '.map' do

    it 'creates a bunch of mapping methods' do
      subject.map(to: :foo, from: :bar)
      subject.map(to: :bar, from: :foo)

      expect(subject.new(bar: :my_to_convert, foo: :my_result).call).to eq [{ foo: :my_to_convert, bar: :my_result },
                                                                            { foo: :my_to_convert, bar: :my_result }]
    end

    it 'delegates to TransformationCommand.create' do
      expect(Yaoc::TransformationCommand).to receive(:create).with(to: :bar, from: :foo, deferred: false, conversion_proc: kind_of(Proc)).and_return(->(*) {})
      subject.map(to: :bar, from: :foo, converter: ->(*) {})
    end

  end

  describe '#converter_methods' do
    it 'preserves method order' do
      subject.map(to: 0, from: 1, converter: ->(*) {})
      subject.map(to: 1, from: :a, converter: ->(*) {})

      expect(subject.converter_methods).to eq [:map_0000_1_to_0, :map_0001_a_to_1]
    end
  end

  describe '#fetcher' do
    let(:subject_with_fetcher)do
      Struct.new(:to_convert) do
        include Yaoc::MappingBase

        def fetcher
          'my_fetcher'
        end

      end
    end

    it 'uses in class declared fetcher' do
      expect(subject_with_fetcher.new.fetcher).to eq 'my_fetcher'
    end

    it 'uses build in fetcher without a fetcher definition' do
      expect(subject.new.fetcher).to eq :fetch
    end

  end

  describe '#call' do
    let(:mapper)do
      subject.new(:some_thing)
    end

    it 'delegates execution to strategy' do
      expect(subject.mapping_strategy).to receive(:call).with mapper

      mapper.call
    end

    it 'return nil when to_convert is nil' do
      mapper.to_convert = nil
      expect(mapper.call).to be_nil
    end

  end

  describe '#to_proc' do
    it 'creates a wrapper around call' do
      mapper = subject.new
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
        fail 'MyException'
      end

      expect(mapper).to receive(:to_convert=).ordered.with(:some_thing)
      expect(mapper).to receive(:to_convert=).ordered.with(:old_some_thing)

      expect { mapper_as_proc.call(:some_thing) }.to raise_error 'MyException'
    end
  end

end
