require "spec_helper"

describe Yaoc::MappingBase do
  subject{
    Struct.new(:to_convert) do
      include Yaoc::MappingBase

      def self.converter_proc(to, from)
        -> (to_convert, result){
          [to, from, to_convert, result]
        }
      end

      def call
        result = :my_result
        converter_methods.map do |method_name|
          self.public_send(method_name, to_convert, result)
        end
      end

    end
  }

  describe ".map" do

    it "creates a bunch of mapping methods" do
      subject.map(:foo, :bar)
      subject.map(:bar, :foo)

      expect(subject.new(:my_to_convert).call()).to eq [[:foo, :bar, :my_to_convert, :my_result],
                                                        [:bar, :foo, :my_to_convert, :my_result]]
    end

    it "uses my converter when provided" do
      subject.map(:bar, :foo, ->(*){})

      expect(subject.new(:my_to_convert).call()).to eq [nil]
    end
  end

  describe "#converter_methods" do
    it "preserves method order" do
      subject.map(0, 1, ->(*){})
      subject.map(1, :a, ->(*){})

      expect(subject.converter_methods).to eq [:map_0000_1_to_0, :map_0001_a_to_1]
    end
  end

  describe "#fetcher" do
    let(:subject_with_fetcher){
      Struct.new(:to_convert) do
        include Yaoc::MappingBase

        def self.create_block(to, from)
          -> (to_convert, result){
            [to, from, to_convert, result]
          }
        end

        def call
          result = nil

          converter_methods.map do |method_name|
            self.public_send(method_name, to_convert, result)
          end
        end

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

end