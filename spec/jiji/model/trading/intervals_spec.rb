# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Intervals do
  let(:intervals) { Jiji::Model::Trading::Intervals.instance }

  describe '#get' do
    it 'idに対応するIntervalを取得できる' do
      interval = intervals.get(:one_minute)
      expect(interval.id).to eq(:one_minute)
      expect(interval.ms).to eq(60 * 1000)

      interval = intervals.get(:thirty_minutes)
      expect(interval.id).to eq(:thirty_minutes)
      expect(interval.ms).to eq(30 * 60 * 1000)
    end

    it 'idに対応するIntervalが存在しない場合エラー' do
      expect do
        intervals.get(:not_found)
      end.to raise_error(Errors::NotFoundException)
    end
  end

  describe '#all' do
    it '一覧を取得できる' do
      all = intervals.all
      expect(all.size).to eq(6)
    end
  end

  describe '#resolve_collecting_interval' do
    it 'idに対応するIntervalのミリ秒値を取得できる' do
      interval_ms = intervals.resolve_collecting_interval(:one_minute)
      expect(interval_ms).to eq(60 * 1000)

      interval_ms = intervals.resolve_collecting_interval(:thirty_minutes)
      expect(interval_ms).to eq(30 * 60 * 1000)
    end

    it 'idに対応するIntervalが存在しない場合エラー' do
      expect do
        intervals.resolve_collecting_interval(:not_found)
      end.to raise_error(Errors::NotFoundException)
    end
  end

  describe '#calcurate_interval_start_time' do
    it '集計期間の開始時刻を計算できる' do
      interval = intervals.get(:fifteen_minutes)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 10, 32))
      ).to eq Time.utc(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 0, 0))
      ).to eq Time.utc(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 14, 59))
      ).to eq Time.utc(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 15, 0))
      ).to eq Time.utc(2015, 5, 1, 12, 15, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 15, 01))
      ).to eq Time.utc(2015, 5, 1, 12, 15, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 13, 15, 01))
      ).to eq Time.utc(2015, 5, 1, 13, 15, 0)

      interval = intervals.get(:one_day)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 10, 32))
      ).to eq Time.utc(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 0, 0))
      ).to eq Time.utc(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 12, 14, 59))
      ).to eq Time.utc(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 20, 15, 00))
      ).to eq Time.utc(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 1, 23, 59, 59))
      ).to eq Time.utc(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(Time.utc(2015, 5, 2, 0, 0, 1))
      ).to eq Time.utc(2015, 5, 2, 0, 0, 0)
    end
    it '集計期間は引数で指定された時刻のタイムゾーンにおける00:00:00を起点に算出される' do
      interval = intervals.get(:fifteen_minutes)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 10, 32))
      ).to eq local(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 0, 0))
      ).to eq local(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 14, 59))
      ).to eq local(2015, 5, 1, 12, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 15, 0))
      ).to eq local(2015, 5, 1, 12, 15, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 15, 01))
      ).to eq local(2015, 5, 1, 12, 15, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 13, 15, 01))
      ).to eq local(2015, 5, 1, 13, 15, 0)

      interval = intervals.get(:one_day)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 10, 32))
      ).to eq local(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 0, 0))
      ).to eq local(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 12, 14, 59))
      ).to eq local(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 20, 15, 00))
      ).to eq local(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 1, 23, 59, 59))
      ).to eq local(2015, 5, 1, 0, 0, 0)
      expect(
        interval.calcurate_interval_start_time(local(2015, 5, 2, 0, 0, 1))
      ).to eq local(2015, 5, 2, 0, 0, 0)
    end

    def local(*args)
      Time.local(*args)
    end
  end
end
