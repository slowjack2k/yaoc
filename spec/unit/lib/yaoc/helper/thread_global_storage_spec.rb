require 'spec_helper'

describe Yaoc::Helper::ThreadGlobalStorage do
  subject{
    Yaoc::Helper::ThreadGlobalStorage
  }

  describe '.for' do
    it 'creates a new object for all threads' do
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

end