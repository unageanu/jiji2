# frozen_string_literal: true

RSpec.shared_examples 'rate_retriever' do
  describe 'retrieve_rate_history' do
    it '通貨ペアの4本値の履歴を取得できる。' do
      rates = client.retrieve_rate_history(:EURJPY, :one_hour,
        Time.utc(2015, 5, 21, 12, 0o0, 0o0), Time.utc(2015, 5, 22, 12, 0, 0))
      # p ticks
      expect(rates.length).to be 24
      time = Time.utc(2015, 5, 21, 12, 0o0, 0o0)
      rates.each do |rate|
        check_rate(rate, time)
        time = Time.at(time.to_i + 60 * 60).utc
      end
    end

    context '週末などでレート情報がない場合、直近の情報で補完される' do
      it '途中のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 4, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 61)

        start_time = Time.local(2015, 5, 1)
        end_time   = Time.local(2015, 5, 15)
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.utc(2015, 5, 1)
        end_time   = Time.utc(2015, 5, 15)
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.utc(2015, 4, 30, 10).localtime('+14:00')
        end_time   = Time.utc(2015, 5, 14, 10).localtime('+14:00')
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.local(2015, 5, 1)
        end_time   = Time.local(2015, 5, 30)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_day, 29)

        start_time = Time.utc(2015, 5, 1)
        end_time   = Time.utc(2015, 5, 30)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_day, 29)
      end

      it '開始時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 3, 17)
        end_time   = Time.utc(2015, 5, 6, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 61)
      end

      it '終了時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 3, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 37)
      end
    end

    def expect_to_enable_retrieve_rates(start_time,
      end_time, interval_id, expected_rate_count)
      rates = client.retrieve_rate_history(
        :EURJPY, interval_id, start_time, end_time)

      interval = Jiji::Model::Trading::Intervals.instance.get(interval_id)
      expect(rates.length).to eq expected_rate_count
      time = interval.calcurate_interval_start_time(start_time)
      rates.each do |rate|
        check_rate(rate, time)
        time = Time.at(time.to_i + (interval.ms / 1000))
      end
    end

    def check_rate(rate, time)
      # puts "#{time} #{rate.timestamp} #{rate.open.bid} #{rate.close.bid}"
      # puts "#{rate.volume}"
      expect(rate.timestamp).to eq time
      expect(rate.open.bid).to be > 0
      expect(rate.open.ask).to be > 0
      expect(rate.close.bid).to be > 0
      expect(rate.close.ask).to be > 0
      expect(rate.high.bid).to be > 0
      expect(rate.high.ask).to be > 0
      expect(rate.low.bid).to be > 0
      expect(rate.low.ask).to be > 0
      expect(rate.volume).to be >= 0
    end
  end
end
