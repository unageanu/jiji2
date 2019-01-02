# frozen_string_literal: true

require 'encase'
require 'jiji/utils/value_object'

module Jiji::Model::Trading
  # 経済カレンダー情報
  class EconomicCalendarInformation

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # イベントのタイトル
    # 例) Chicago PMI
    attr_reader :title

    # イベントのタイムスタンプ
    attr_reader :timestamp

    # forecast, previous, actual の各フィールドにおけるデータの形式。　
    # * % .. パーセント
    # * k .. 1,000単位の数値
    # * index .. インデックス値
    attr_reader :unit

    # ニュースイベントに関連する通貨
    # 例) EUR
    attr_reader :currency

    # フォーキャストの値
    attr_reader :forecast

    # 同イベントの前回リリース時の値
    attr_reader :previous

    # 実際値。
    # イベントが実際に起こった後でのみ、取得可能になります。
    attr_reader :actual

    # 市場が期待した値
    attr_reader :market

    # 地域
    # 例) europe
    attr_reader :region

    # 市場への影響度? (公式APIに記載なし)
    attr_reader :impact

    def initialize(info) #:nodoc:
      @title = info.title
      @timestamp = Time.at(info.timestamp || 0)
      @unit = info.unit
      @currency = info.currency
      @forecast = info.forecast
      @previous = info.previous
      @actual = info.actual
      @market = info.market
      @region = info.region
      @impact = info.impact
    end

  end
end
