require 'spec_helper'

describe Yaoc::Helper::StructHashConstructor do
  subject{
    Yaoc::Helper::StructH(:id, :name).new(id: 1, name: "no name")
  }
  it "creates a struct with a hash enabled constructor" do
    expect(subject.id).to eq 1
    expect(subject.name).to eq "no name"
  end

end