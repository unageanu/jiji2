# frozen_string_literal: true

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

  describe '#iana_name' do
    it '+1400' do
      expect(iana_name(Time.now.localtime('+14:00'))).to eq 'Pacific/Kiritimati'
    end
    it '+900' do
      expect(iana_name(Time.now.localtime('+09:00'))).to eq 'Asia/Tokyo'
    end
    it '+500' do
      expect(iana_name(Time.now.localtime('+05:00'))).to eq 'Asia/Samarkand'
    end
    it '+530' do
      expect(iana_name(Time.now.localtime('+05:30'))).to eq 'Asia/Calcutta'
    end
    it '+545' do
      expect(iana_name(Time.now.localtime('+05:45'))).to eq 'Asia/Kathmandu'
    end
    it '0' do
      expect(iana_name(Time.now.localtime('+00:00'))).to eq 'UTC'
      expect(iana_name(Time.now.utc)).to eq 'UTC'
    end
    it '-900' do
      expect(iana_name(Time.now.localtime('-09:00'))).to eq 'US/Alaska'
    end
    it '-930' do
      expect(iana_name(Time.now.localtime('-09:30'))).to eq 'Pacific/Marquesas'
    end
    it '-1000' do
      expect(iana_name(Time.now.localtime('-10:00'))).to eq 'US/Hawaii'
    end
    it '対応するタイムゾーンが存在しない場合、エラーになる' do
      expect do
        iana_name(Time.now.localtime('+10:10'))
      end.to raise_error(ArgumentError)
    end
  end

  def iana_name(time)
    Jiji::Utils::Times.iana_name(time)
  end

  def round_day(time)
    Jiji::Utils::Times.round_day(time)
  end

  def yesterday(time)
    Jiji::Utils::Times.yesterday(time)
  end
end
