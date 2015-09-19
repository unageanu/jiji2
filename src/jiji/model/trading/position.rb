# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'
require 'jiji/model/trading/internal/position_internal_functions'

module Jiji::Model::Trading
  class Position

    include Mongoid::Document
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

    field :internal_id,    type: String

    field :pair_name,      type: Symbol
    field :units,          type: Integer
    field :sell_or_buy,    type: Symbol
    field :status,         type: Symbol

    field :profit_or_loss, type: Float
    field :max_drow_down,  type: Float

    field :entry_price,    type: Float
    field :current_price,  type: Float
    field :exit_price,     type: Float

    field :entered_at,     type: Time
    field :exited_at,      type: Time
    field :updated_at,     type: Time

    embeds_one :closing_policy

    index(
      { backtest_id: 1 },
      name: 'positions_backtest_id_index')

    index(
      { backtest_id: 1, profit_or_loss: -1 },
      name: 'positions_backtest_id_profit_or_loass_index')

    attr_readonly :internal_id

    def initialize(*args)
      super(*args)
      update_profit_or_loss
    end

    def attach_broker(broker)
      @broker = broker
    end

    def to_h
      h = {}
      insert_trading_information_to_hash(h)
      insert_price_and_time_information_to_hash(h)
      insert_backtest_information_to_hash(h)
      insert_agent_information_to_hash(h)
      h[:closing_policy] = closing_policy.to_h
      h
    end

    def modify
      @broker.modify_position(self) if @broker
    end

    def close
      illegal_state unless @broker
      @broker.close_position(self)
    end

  end
end
