# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Intervals do

  before(:example) do
    @intervals = Jiji::Model::Trading::Intervals.instance
  end

  describe '#get' do
    it 'idに対応するIntervalを取得できる' do
      interval = @intervals.get(:one_minute)
      expect(interval.id).to eq(:one_minute)
      expect(interval.ms).to eq(60*1000)

      interval = @intervals.get(:thirty_minutes)
      expect(interval.id).to eq(:thirty_minutes)
      expect(interval.ms).to eq(30*60*1000)
    end

    it 'idに対応するIntervalが存在しない場合エラー' do
      expect do
        @intervals.get(:not_found)
      end.to raise_error(Errors::NotFoundException)
    end
  end

  describe '#all' do
    it '一覧を取得できる' do
      all = @intervals.all
      expect(all.size).to eq(6)
    end
  end

  describe '#resolve_collecting_interval' do
    it 'idに対応するIntervalのミリ秒値を取得できる' do
      interval_ms = @intervals.resolve_collecting_interval(:one_minute)
      expect(interval_ms).to eq(60*1000)

      interval_ms = @intervals.resolve_collecting_interval(:thirty_minutes)
      expect(interval_ms).to eq(30*60*1000)
    end

    it 'idに対応するIntervalが存在しない場合エラー' do
      expect do
        @intervals.resolve_collecting_interval(:not_found)
      end.to raise_error(Errors::NotFoundException)
    end
  end
end
