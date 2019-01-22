# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Pairs do
  include_context 'use data_builder'
  include_context 'use container'
  let(:pairs) { container.lookup(:pairs) }
  let(:securities_provider) { container.lookup(:securities_provider) }
  let(:securities_factory) { container.lookup(:securities_factory) }

  describe 'get_by_name' do
    it '名前に対応する通貨ペアを取得できる' do
      pair = pairs.get_by_name(:EURJPY)
      expect(pair.name).to eq(:EURJPY)
      pair = pairs.get_by_name(:EURUSD)
      expect(pair.name).to eq(:EURUSD)
    end

    it '名前に対応する通貨ペアが存在しない場合エラー' do
      expect do
        pairs.get_by_name(:NOT_FOUND)
      end.to raise_error(Errors::NotFoundException)
    end
  end

  describe 'reload' do
    it '一覧を再読み込みできる' do
      pairs.all
      securities_provider.get.pairs = [
        Jiji::Model::Trading::Pair.new(
          :EURJPY, 'EUR_JPY', 0.01, 10_000_000, 0.001, 0.04)
      ]
      expect(pairs.all.size).to eq(3)

      pairs.reload
      all = pairs.all
      expect(all.size).to eq(1)
      expect(all[0].name).to eq(:EURJPY)
    end
  end

  it 'allで通貨ペア一覧を取得できる' do
    all = pairs.all
    expect(all.size).to eq(3)
    expect(all[0].name).to eq(:EURJPY)
    expect(all[1].name).to eq(:EURUSD)
    expect(all[2].name).to eq(:USDJPY)
  end

  it '証券会社が変更されると、一覧が再読み込みされる' do
    securities = securities_factory.create(:MOCK)
    securities.pairs = [
      Jiji::Model::Trading::Pair.new(
        :EURJPY, 'EUR_JPY', 0.01, 10_000_000, 0.001, 0.04)
    ]
    expect(pairs.all.size).to eq(3)

    securities_provider.set securities
    all = pairs.all
    expect(all.size).to eq(1)
    expect(all[0].name).to eq(:EURJPY)
  end
end
