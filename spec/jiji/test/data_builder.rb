# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all('jiji/model')

module Jiji::Test
  class DataBuilder

    include Jiji::Model::Trading

    def new_rate(seed, pair_name = :EURJPY)
      Rate.create_from_tick(
        pair_name, new_tick(seed), new_tick(seed + 1),
        new_tick(seed + 9), new_tick(seed - 11)
      )
    end

    def new_tick(seed, timestamp = Time.at(0))
      pairs  = [:EURJPY, :USDJPY, :EURUSD]
      values = pairs.each_with_object({}) do |pair_name, r|
        r[pair_name] = new_tick_value(seed)
        r
      end
      Tick.new(values, timestamp)
    end

    def new_tick_value(seed)
      Tick::Value.new(100.00 + seed, 100.003 + seed)
    end

    def new_position(seed, backtest_id = nil,
        pair_name = :EURJPY, timestamp = Time.at(seed))
      position_builder = Internal::PositionBuilder.new(backtest_id)
      position_builder.build_from_tick(seed, pair_name,
        seed * 10_000, seed.even? ? :buy : :sell, new_tick(seed, timestamp))
    end

    def new_agent_body(seed, parent = nil)
      <<BODY
class TestAgent#{seed} #{ parent ? ' < ' + parent : '' }

  include Jiji::Model::Agents::Agent

  def self.property_infos
    return [
      Property.new(:a, "aa", 1),
      Property.new(:b, "bb", #{seed})
    ]
  end

  def self.description
    "description#{seed}"
  end

end
BODY
    end

    def new_trading_context(broker = Mock::MockBroker.new,
      time_source = Jiji::Utils::TimeSource.new, logger = Logger.new(STDOUT))
      agents = Jiji::Model::Agents::Agents.new
      graph_factory = Jiji::Model::Graphing::GraphFactory.new
      TradingContext.new(agents, broker, graph_factory, time_source, logger)
    end

    def new_order(seed, internal_id = seed.to_s,
      pair_name = :EURJPY, type = :market, timestamp = Time.at(seed))
      order = Jiji::Model::Trading::Order.new(
        pair_name, internal_id, seed.even? ? :buy : :sell, type, timestamp)
      order.units         = seed * 10_000
      order.price         = 100 + seed
      order.expiry        = timestamp + 10
      order.lower_bound   = 99 + seed
      order.upper_bound   = 101 + seed
      order.stop_loss     = (seed.even? ? 98 : 102) + seed
      order.take_profit   = (seed.even? ? 102 : 98) + seed
      order.trailing_stop = seed
      order
    end

    def new_closed_position(seed, internal_id = seed.to_s,
      units = seed * 10_000, price = 100 + seed, timestamp = Time.at(seed))
      Jiji::Model::Trading::ClosedPosition.new(
        internal_id, units, price, timestamp)
    end

    def new_reduced_position(seed, internal_id = seed.to_s,
      units = seed * 1000, price = 100 + seed, timestamp = Time.at(seed))
      Jiji::Model::Trading::ReducedPosition.new(
        internal_id, units, price, timestamp)
    end

    def new_order_result(order_opened,
      trade_opened = nil, trade_reduced = nil, trades_closed = [])
      Jiji::Model::Trading::OrderResult.new(
        order_opened, trade_opened, trade_reduced, trades_closed)
    end

    def register_backtest(seed, repository)
      repository.register(
        'name'          => "テスト#{seed}",
        'start_time'    => Time.at(seed * 100),
        'end_time'      => Time.at((seed + 1) * 200),
        'memo'          => "メモ#{seed}",
        'pair_names'    => [:EURJPY, :EURUSD],
        'agent_setting' => [
          { name: 'TestAgent1@aaa', properties: { 'a' => 100, 'b' => 'bb' } }
        ]
      )
    end

    def register_agent(seed)
      Jiji::Model::Agents::AgentSource.create(
        "test#{seed}", seed.even? ? :agent : :lib, Time.at(100 * seed), '',
        "class Foo#{seed}; def to_s; return \"xxx#{seed}\"; end; end")
    end

    def clean
      BackTest.delete_all
      Position.delete_all
      Jiji::Model::Agents::AgentSource.delete_all
      Jiji::Model::Agents::Agents.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
      Jiji::Model::Graphing::GraphData.delete_all
      Jiji::Model::Graphing::Graph.delete_all
      Mail::TestMailer.deliveries.clear
    end

  end
end
