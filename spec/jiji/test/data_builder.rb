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
      Tick::Value.new( 100.00 + seed, 100.003 + seed)
    end

    def new_position(seed, back_test_id = nil,
        pair_id = 1, timestamp = Time.at(seed))
      Position.create(back_test_id, nil, pair_id,
        seed, 10_000, seed.even? ? :buy : :sell, new_tick(seed, timestamp))
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
      TradingContext.new(nil, broker, time_source, logger)
    end

    def register_back_test(seed, repository)
      repository.register(
        'name'       => "テスト#{seed}",
        'start_time' => Time.at(seed * 100),
        'end_time'   => Time.at((seed + 1) * 200),
        'memo'       => "メモ#{seed}")
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
      Jiji::Model::Settings::AbstractSetting.delete_all
      Jiji::Model::Graphing::GraphData.delete_all
      Jiji::Model::Graphing::Graph.delete_all
      Mail::TestMailer.deliveries.clear
    end

  end
end
