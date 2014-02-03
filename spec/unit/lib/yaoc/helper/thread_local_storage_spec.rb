require 'spec_helper'

describe Yaoc::Helper::ThreadLocalStorage do
  subject{
    Yaoc::Helper::ThreadLocalStorage
  }

  let(:storage){
    subject.for
  }

  describe '.for' do
    it 'creates a new object for every thread' do
      subject.for

      threat_one_object_id = nil
      threat_two_object_id = nil
      threats = []

      threats << Thread.new{
        threat_one_object_id = Yaoc::Helper::ThreadLocalStorage.for
      }

      threats << Thread.new{
        threat_two_object_id = Yaoc::Helper::ThreadLocalStorage.for
      }

      threats.each &:join

      expect(threat_one_object_id).not_to eq  threat_two_object_id
    end

    it 'supports naming different scopes' do
      second_scope = subject.for 'the second scope'
      expect(second_scope.object_id).not_to be subject.for.object_id
    end
  end

  it 'supports hash like accessors' do
    storage['key'] = 1
    expect(storage['key']).to eq 1
    expect(storage.fetch 'key').to eq 1

    storage.clear!

    expect(storage['key']).to be_nil

  end

end