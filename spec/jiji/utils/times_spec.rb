# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Utils::Times do
  describe '#yesterday' do
    it '前の日を取得できる' do
      expect(yesterday(Time.local(2015, 1, 1, 23, 59, 59)))
        .to eq Time.local(2014, 12, 31, 0, 0, 0)
      expect(yesterday(Time.local(2015, 1, 1, 0, 0, 0)))
        .to eq Time.local(2014, 12, 31, 0, 0, 0)
      expect(yesterday(Time.local(2015, 1, 2, 10, 0, 0)))
        .to eq Time.local(2015, 1, 1, 0, 0, 0)
      expect(yesterday(Time.local(2015, 2, 1, 8, 0, 0)))
        .to eq Time.local(2015, 1, 31, 0, 0, 0)
    end
    it 'タイムゾーンは引数のTimeから引き継ぐ' do
      expect(yesterday(Time.local(2015, 1, 1, 23, 59, 59)))
        .to eq Time.local(2014, 12, 31, 0, 0, 0)
      expect(yesterday(Time.utc(2015, 1, 1, 23, 59, 59)))
        .to eq Time.utc(2014, 12, 31, 0, 0, 0)
    end
  end

  describe '#round_day' do
    it '同じ日の00:00:00に丸められる' do
      expect(round_day(Time.local(2015, 1, 1, 23, 59, 59)))
        .to eq Time.local(2015, 1, 1, 0, 0, 0)
    end
    it 'タイムゾーンは引数のTimeから引き継ぐ' do
      expect(round_day(Time.local(2015, 1, 1, 1, 1, 1)))
        .to eq Time.local(2015, 1, 1, 0, 0, 0)
      expect(round_day(Time.utc(2015, 1, 1, 1, 1, 1)))
        .to eq Time.utc(2015, 1, 1, 0, 0, 0)
    end
  end

  def round_day(time)
    Jiji::Utils::Times.round_day(time)
  end

  def yesterday(time)
    Jiji::Utils::Times.yesterday(time)
  end
end
