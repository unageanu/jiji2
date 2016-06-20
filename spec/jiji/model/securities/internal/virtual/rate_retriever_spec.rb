# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Securities::Internal::Virtual::RateRetriever do
  let(:wait) { 0 }

  it 'pair が取得できる' do
    client = Jiji::Test::VirtualSecuritiesBuilder.build

    pairs = client.retrieve_pairs
    expect(pairs.length).to be 5
    expect(pairs[0].name).to be :EURJPY
    expect(pairs[1].name).to be :USDJPY
    expect(pairs[2].name).to be :AUDCAD
    expect(pairs[3].name).to be :CADJPY
    expect(pairs[4].name).to be :EURDKK
  end

  describe '#retrieve_current_tick' do
    it '期間内のレートを取得できる' do
      client = Jiji::Test::VirtualSecuritiesBuilder.build
      expect(client.next?).to be true
      rates = client.retrieve_current_tick
      expect(rates[:EURJPY].bid).to eq 128.841
      expect(rates[:EURJPY].ask).to eq 128.87
      expect(rates[:USDJPY].bid).to eq 119.964
      expect(rates[:USDJPY].ask).to eq 119.985
      expect(rates.timestamp).to eq Time.utc(2015, 4, 1)

      expect(client.next?).to be true
      rates = client.retrieve_current_tick
      expect(rates[:EURJPY].bid).to eq 128.819
      expect(rates[:EURJPY].ask).to eq 128.846
      expect(rates[:USDJPY].bid).to eq 119.94
      expect(rates[:USDJPY].ask).to eq 119.96
      expect(rates.timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 15)

      (4 * 60 * 6 - 2).times do |i|
        expect(client.next?).to be true
        rates = client.retrieve_current_tick
        expect(rates[:EURJPY].bid).to be > 0
        expect(rates[:EURJPY].ask).to be > 0
        expect(rates[:USDJPY].bid).to be > 0
        expect(rates[:USDJPY].ask).to be > 0
        expect(rates.timestamp).to eq(Time.utc(2015, 4, 1, 0, 0, 30) + 15 * i)
      end

      expect(client.next?).to be false
    end

    context '週末などでレート情報がない場合、直近の情報で補完される' do
      it '途中のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 4, 6)
        expect_to_enable_retrieve_ticks(start_time, end_time)
      end

      it '開始時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 3, 17)
        end_time   = Time.utc(2015, 5, 4, 6)
        expect_to_enable_retrieve_ticks(start_time, end_time)
      end

      it '終了時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 2, 6)
        expect_to_enable_retrieve_ticks(start_time, end_time)
      end
    end

    def expect_to_enable_retrieve_ticks(start_time, end_time)
      client = Jiji::Test::VirtualSecuritiesBuilder.build(
        start_time, end_time)

      ((end_time.to_i - start_time.to_i) / 15).times do |i|
        expect(client.next?).to be true
        rates = client.retrieve_current_tick
        expect(rates[:EURJPY].bid).to be > 0
        expect(rates[:EURJPY].ask).to be > 0
        expect(rates[:USDJPY].bid).to be > 0
        expect(rates[:USDJPY].ask).to be > 0
        expect(rates.timestamp).to eq(start_time + 15 * i)
      end
    end
  end
end if ENV['OANDA_API_ACCESS_TOKEN']
