# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'
require 'jiji/model/trading/internal/position_internal_functions'
require 'jiji/utils/bulk_write_operation_support'

module Jiji::Model::Trading
  # 建玉
  #
  #  position = broker.positions[0]
  #
  #  position.internal_id     # 一意な識別子
  #  position.pair_name       # 通貨ペア 例) :EURJPY
  #  position.units           # 取引単位
  #  position.sell_or_buy     # 売(:sell) or 買(:buy)
  #
  #  # ステータス
  #  # - 新規   .. :live
  #  # - 決済済 .. :closed
  #  # - ロスト .. :lost
  #  #   (決済前にシステムが再起動された場合、ロスト状態になります)
  #  position.status
  #
  #  position.profit_or_loss  # 損益
  #  position.max_drow_down   # 最大ドローダウン
  #
  #  position.entry_price     # 購入価格
  #  position.current_price   # 現在価格
  #  position.exit_price      # 決済価格 (未決済の場合 nil)
  #
  #  position.entered_at      # 購入日時
  #  position.exited_at       # 決済日時 (未決済の場合 nil)
  #  position.updated_at      # 最終更新時刻
  #
  #  # 決済条件
  #  position.closing_policy.take_profit     # テイクプロフィット価格
  #  position.closing_policy.stop_loss       # ストップロス価格
  #  position.closing_policy.trailing_stop   # トレーリングストップディスタンス
  #  position.closing_policy.trailing_amount # トレーリングストップ数量
  #
  class Position

    include Mongoid::Document
    include Jiji::Utils::BulkWriteOperationSupport
    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Utils
    include Internal::PositionInternalFunctions

    store_in collection: 'positions'
    belongs_to :agent, {
      class_name: 'Jiji::Model::Agents::AgentSetting'
    }
    belongs_to :backtest, {
      class_name: 'Jiji::Model::Trading::BackTestProperties'
    }

    field :internal_id,           type: String

    field :pair_name,             type: Symbol
    field :units,                 type: Integer
    field :sell_or_buy,           type: Symbol
    field :status,                type: Symbol

    field :profit_or_loss,        type: Float
    field :max_drow_down,         type: Float

    field :entry_price,           type: Float
    field :current_price,         type: Float
    field :exit_price,            type: Float
    field :current_counter_rate,  type: Float

    field :entered_at,            type: Time
    field :exited_at,             type: Time
    field :updated_at,            type: Time

    embeds_one :closing_policy

    index(
      { backtest_id: 1 },
      name: 'positions_backtest_id_index')

    index(
      { backtest_id: 1, profit_or_loss: -1 },
      name: 'positions_backtest_id_profit_or_loass_index')

    attr_readonly :internal_id

    def initialize(*args) #:nodoc:
      super(*args)
      update_profit_or_loss
    end

    def attach_broker(broker) #:nodoc:
      @broker = broker
    end

    def to_h #:nodoc:
      h = {}
      insert_trading_information_to_hash(h)
      insert_price_and_time_information_to_hash(h)
      insert_backtest_information_to_hash(h)
      insert_agent_information_to_hash(h)
      h[:closing_policy] = closing_policy.to_h
      h
    end

    # 建玉の変更を反映します。
    def modify
      @broker.modify_position(self) if @broker
    end

    # 建玉を決済します。
    def close
      illegal_state unless @broker
      @broker.close_position(self)
    end

  end
end
