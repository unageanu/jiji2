# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Tick::Value do
  describe '#mid' do
    it 'retuns the price between ask and bid.' do
      value = Jiji::Model::Trading::Tick::Value.new(108.052, 108.056)
      expect(value.mid).to eq 108.054

      value = Jiji::Model::Trading::Tick::Value.new(1.5052, 1.5055)
      expect(value.mid).to eq 1.50535
    end
  end
end
