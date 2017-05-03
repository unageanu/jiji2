# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all('jiji/model')

module Jiji::Test
  class DataBuilder

    include Jiji::Model::Trading

    def initialize
      Jiji::Model::Logging::LogData.drop
      Jiji::Model::Notification::Notification.drop
      Jiji::Db::CreateCappedCollections.new({
        notifications: { size: 20 * 1024 * 1024 },
        log_data:      { size: 50 * 1024 * 1024 }
      }).call(nil, nil)
    end

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
      Tick::Value.new(
        (BigDecimal.new(100, 10) + seed).to_f,
        (BigDecimal.new(100.003, 10) + seed).to_f)
    end

    def new_position(seed, backtest = nil, agent = nil,
      pair_name = :EURJPY, timestamp = Time.at(seed))
      position_builder = Internal::PositionBuilder.new(backtest)
      position = position_builder.build_from_tick(seed, pair_name,
        seed * 10_000, seed.even? ? :buy : :sell,
        new_tick(seed, timestamp), 'JPY')
      position.agent = agent
      position
    end

    def new_agent_body(seed, parent = nil)
      <<BODY
class TestAgent#{seed} #{parent ? ' < ' + parent : ''}

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

  def state
    fail "test" if agent_name =~ /state_error/
    return nil  if agent_name =~ /state_nil/
    {:name => agent_name, :number => #{seed} }
  end

  def restore_state(state)
    fail "test" if agent_name =~ /restore_state_error/
    @restored_state = state
  end

  attr_reader :restored_state

end
BODY
    end

    def new_notification_agent_body(seed, parent = nil)
      <<BODY
class TestAgent#{seed} #{parent ? ' < ' + parent : ''}

  include Jiji::Model::Agents::Agent

  def post_create
    notifier.push_notification('テスト通知', [
      {label: "アクション1", action: "aaa"},
      {label: "アクション2", action: "bbb"}
    ])
  end

  def execute_action(action)
    fail "test" if action == "error"
    notifier.push_notification("do action " + action)
    return "OK " + action
  end

end
BODY
    end

    def new_trading_context(broker = Mock::MockBroker.new, agents = nil,
      time_source = Jiji::Utils::TimeSource.new, logger = Logger.new(STDOUT))
      graph_factory = Jiji::Model::Graphing::GraphFactory.new
      agents ||= Jiji::Model::Agents::Agents.new(nil, nil, {
        logger:        logger,
        time_source:   time_source,
        bloker:        broker,
        graph_factory: graph_factory
      })
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
      units = seed * 10_000, price = 100 + seed, timestamp = Time.at(seed),
      profit = nil)
      Jiji::Model::Trading::ClosedPosition.new(
        internal_id, units, price, timestamp, profit)
    end

    def new_reduced_position(seed, internal_id = seed.to_s,
      units = seed * 1000, price = 100 + seed, timestamp = Time.at(seed),
      profit = nil)
      Jiji::Model::Trading::ReducedPosition.new(
        internal_id, units, price, timestamp, profit)
    end

    def new_order_result(order_opened,
      trade_opened = nil, trade_reduced = nil, trades_closed = [])
      Jiji::Model::Trading::OrderResult.new(
        order_opened, trade_opened, trade_reduced, trades_closed)
    end

    def new_notification(seed, agent_setting = nil,
      backtest = nil, timestamp = Time.at(seed))
      actions = [
        { 'label' => 'あ', 'action' => 'aaa' },
        { 'label' => 'い', 'action' => 'bbb' }
      ]
      Jiji::Model::Notification::Notification.create(
        agent_setting, Time.at(seed), backtest, "message#{seed}", actions)
    end

    def register_backtest(seed, repository,
      start_time = Time.at(seed * 100), end_time = Time.at((seed + 1) * 200))
      repository.register(
        'name'          => "テスト#{seed}",
        'start_time'    => start_time,
        'end_time'      => end_time,
        'balance'       => 1_000_000,
        'memo'          => "メモ#{seed}",
        'pair_names'    => [:EURJPY, :EURUSD],
        'agent_setting' => [
          {
            agent_class: 'TestAgent1@aaa',
            properties:  { 'a' => 100, 'b' => 'bb' }
          }
        ]
      )
    end

    def register_agent(seed)
      source = Jiji::Model::Agents::AgentSource.create(
        "test#{seed}", seed.even? ? :agent : :lib, Time.at(100 * seed), '',
        "class Foo#{seed}; def to_s; return \"xxx#{seed}\"; end; end")
      source.save
      source
    end

    def register_agent_setting(name = 'test1',
      icon = BSON::ObjectId.from_time(Time.new))
      setting = Jiji::Model::Agents::AgentSetting.new
      setting.name        = name
      setting.agent_class = 'testClass1'
      setting.icon_id     = BSON::ObjectId.from_time(Time.new)
      setting.save
      setting
    end

    def clean
      BackTest.delete_all
      Position.delete_all
      Jiji::Model::Agents::AgentSource.delete_all
      Jiji::Model::Agents::AgentSetting.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
      Jiji::Model::Graphing::GraphData.delete_all
      Jiji::Model::Graphing::Graph.delete_all
      Jiji::Model::Logging::LogData.drop
      Jiji::Model::Notification::Notification.drop
      Jiji::Model::Icons::Icon.delete_all
      Jiji::Messaging::Device.delete_all
      Jiji::Db::SchemeStatus.delete_all
      Mail::TestMailer.deliveries.clear
    end

    def cancel_all_orders_and_positions(client, wait = 1)
      client.retrieve_orders.each do |o|
        sleep wait
        begin
          client.cancel_order(o.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
      sleep wait
      client.retrieve_trades.each do |t|
        sleep wait
        begin
          client.close_trade(t.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
    end

    def read_image_date(name)
      File.open("#{base_dir}/sample_images/#{name}") { |f| f.read }
    end

    def base_dir
      File.expand_path('../', __FILE__)
    end

    def new_python_agent_body(id = '1')
      <<SOURCE.freeze
import datetime
from jiji.model.agent import Agent, Property

class TestAgent(Agent):

    @staticmethod
    def get_description():
        return "description#{id}"

    @staticmethod
    def get_property_infos():
        return [
            Property("a", "プロパティ1", "aa"),
            Property("b", "プロパティ2")
        ]

    def set_properties(self, properties):
        self.properties = properties

    def post_create(self):
        self.firsttime = True
        self.x = 0
        self.logger.info("properties:" + self.properties["a"] + "_" + self.properties["b"])

        for pair in self.broker.get_pairs().values():
            self.logger.info("pair:" + pair.name + " " + pair.internal_id \
                + " " + str(pair.pip) + " " + str(pair.max_trade_units) + " " + str(pair.precision) \
                + " " + str(pair.margin_rate))

    def next_tick(self, tick):
        self._print_tick("tick", tick, "EURJPY")
        self.last_tick = tick

        if self.firsttime:
            new_tick = self.broker.get_tick()
            self._print_tick("get_tick", new_tick, "EURUSD")
            rates = self.broker.retrieve_rates('EURJPY', 'one_minute', \
              datetime.datetime(2017, 4, 3, 12, 0, 0), datetime.datetime(2017, 4, 3, 13, 0, 0))
            for rate in rates:
                self.logger.warn("rate:" + str(rate.open.ask) + " " + str(rate.open.bid) + " " \
                    + str(rate.close.ask) + " " + str(rate.close.bid) + " " \
                    + str(rate.high.ask) + " " + str(rate.high.bid) + " " \
                    + str(rate.low.ask) + " " + str(rate.low.bid) + " " \
                    + str(rate.volume) + " " + rate.timestamp.isoformat())

            self.print_account()
            self.firsttime = False

    def save_state(self):
        state = self.properties.copy()
        state["x"] = self.x + 1
        return state

    def restore_state(self, state):
        print(state)
        self.x = state["x"]

    def execute_action(self, action):
        if action == "get_properties":
          return self.properties["a"] + "_" + self.properties["b"]
        elif action == "get_last_tick":
          timezone = datetime.timezone(datetime.timedelta(0))
          time = self.last_tick.timestamp.replace(tzinfo=timezone)
          return str(self.last_tick['USDJPY'].bid) \
            + "_" + str(self.last_tick['USDJPY'].ask) \
            + "_" + str(time)
        elif action == "error":
          raise Exception("error")

    def print_account(self):
        account = self.broker.get_account()
        self.logger.info("account: {0} {1} {2} {3} {4} {5} {6}".format(
          account.balance, account.account_id, \
          account.margin_rate, account.margin_used, account.profit_or_loss, account.updated_at, \
          account.account_currency))

    def create_order(self):
        self.broker.order()

    def _print_tick(self, id, tick, pair):
        self.logger.warn(id + ":" + str(tick[pair].bid) + " " + str(tick[pair].ask) + " " + tick.timestamp.isoformat())

SOURCE
    end

  end
end
