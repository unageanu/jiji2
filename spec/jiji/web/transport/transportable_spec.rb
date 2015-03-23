# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Web::Transport::Transportable do
  shared_examples '各種オブジェクトをシリアライズ/デシリアライズできる' do
    it 'Time' do
      data = Time.new(2010, 1, 1, 0, 0, 0, "+09:00")
      expect(@converter.call(data)).to eq '2010-01-01T00:00:00+09:00'
    end

    it 'Struct' do
      data = Struct.new(:a, :b).new('a', 'b')
      expect(@converter.call(data)).to eq('a' => 'a', 'b' => 'b')
      expect(@converter.call([data])).to eq(['a' => 'a', 'b' => 'b'])
    end
  end

  describe 'messagepack' do
    before(:example) do
      @converter = proc { |v| MessagePack.unpack(MessagePack.pack(v)) }
    end

    it_behaves_like '各種オブジェクトをシリアライズ/デシリアライズできる'
  end

  describe 'json' do
    before(:example) do
      @converter = proc { |v| JSON.load(JSON.generate([v]))[0] }
    end

    it_behaves_like '各種オブジェクトをシリアライズ/デシリアライズできる'
  end
end
