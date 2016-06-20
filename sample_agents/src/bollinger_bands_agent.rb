require 'quandl'
require 'lru_redux'

# === ボリンジャーバンドエージェント
class BollingerBandsAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
      ボリンジャーバンドエージェント
    STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new('pair',           '通貨ペア', 'USDJPY'),
      Property.new('trade_units',    '取引数量', 10_000),
      Property.new('distance',       '取引を仕掛ける間隔(sdに対する倍率)', 1),
      Property.new('quandl_api_key', 'Quandl API KEY', '')
    ]
  end

  def post_create
    calculator =
      BollingerBands::BollingerBandsCalculator.new(@quandl_api_key)
    @trader = BollingerBands::Trader.new(
      @pair.to_sym, @trade_units.to_i, @distance.to_f,
      broker, create_index_graph, create_bands_graph, logger, calculator)
  end

  def next_tick(tick)
    @trader.process_tick(tick)
  end

  def create_index_graph
    graph_factory.create('index', :line, :last, ['#779999'])
  end

  def create_bands_graph
    graph_factory.create('rate', :rate, :last, [
      '#FF6633', '#FFAA22', '#FFCC11', '#FFEE00',
      '#FFCC11', '#FFAA22', '#FF6633'
    ])
  end

end

module BollingerBands
  module Utils
    def bd(v)
      BigDecimal.new(v.to_f, 10)
    end

    def sum(array)
      array.inject(0) { |a, e| a + e }
    end

    def mean(array)
      array.sum / array.length.to_f
    end

    def sample_variance(array)
      m = mean(array)
      sum = array.inject(0) { |a, e| a + (e - m)**2 }
      sum / (array.length - 1).to_f
    end

    def standard_deviation(array)
      Math.sqrt(sample_variance(array))
    end
  end

  class BollingerBandsCalculator

    include Utils

    def initialize(api_key)
      Quandl::ApiConfig.api_key = api_key if api_key
      Quandl::ApiConfig.api_version = '2015-04-09'

      @cache = LruRedux::ThreadSafeCache.new(10)
    end

    def calculate(price, timestamp, pair)
      key = timestamp.strftime('%Y-%m-%d')
      @cache[key] \
      || (@cache[key] = calculate_bollinger_bands(price, timestamp, pair))
    end

    def calculate_bollinger_bands(price, timestamp, pair)
      rates = retrieve_rates(timestamp, pair)
      {
        mean: mean(rates).to_f.round(9),
        sd:   standard_deviation(rates).to_f.round(9)
      }
    end

    def retrieve_rates(time, pair)
      retrieve_rates_from_quandl(time, pair).map do |e|
        e['rate']
      end
    end

    def retrieve_rates_from_quandl(time, pair)
      Quandl::Dataset.get("CURRFX/#{pair}")
        .data(params: {
          rows:     20,
          end_date: time.strftime('%Y-%m-%d')
        })
    end

  end

  class Trader

    include Utils

    attr_reader :positions
    attr_writer :cointegration_resolver

    def initialize(pair, units, distance, broker,
      index_graph = nil, bands_graph = nil, logger = nil,
      calculator = BollingerBandsCalculator.new)
      @pair          = pair
      @units         = units
      @distance      = distance
      @broker        = broker
      @logger        = logger
      @bands_graph   = bands_graph
      @index_graph   = index_graph
      init
    end

    def init
      @bollinger_bands_calculator = calculator
      @positions = {}
      restore_state
    end

    def process_tick(tick)
      price = bd(tick[@pair].bid)
      bands = calculate_bollinger_bands(price, tick.timestamp, @pair)
      index = calculate_index(price, bands)

      do_takeprofit(index)
      do_trade(tick, bands, index)
    end

    def do_trade(tick, bands, index)
      register_graph_data(bands, index)
      log(tick, bands, index)

      if index != 0 && index != -1 && !@positions.include?(index.to_s)
        @positions[index.to_s] = create_position(index)
      end
    end

    def register_graph_data(bands, index)
      @index_graph << [index] if @index_graph
      @bands_graph << create_bands(bands) if @bands_graph
    end

    def create_bands(bands)
      [-3, -2, -1, 0, 1, 2, 3].map do |i|
        bands[:mean] + i * bands[:sd]
      end
    end

    def log(tick, bands, index)
      return unless @logger
      @logger.info(
        "#{tick.timestamp} #{tick[@pair].bid}" \
      + " #{bands[:sd]} #{bands[:mean]} #{index}")
    end

    def do_takeprofit(index)
      @positions.keys.each do |key|
        @positions.delete(key) if @positions[key].close_if_required(index)
      end
    end

    def create_position(index)
      index < 0 ? buy(index) : sell(index)
    end

    def buy(index)
      position = @broker.buy(@pair, @units).trade_opened
      Position.new(index, @broker.positions[position.internal_id])
    end

    def sell(index)
      position = @broker.sell(@pair, @units).trade_opened
      Position.new(index, @broker.positions[position.internal_id])
    end

    def calculate_bollinger_bands(price, timestamp, pair)
      @bollinger_bands_calculator.calculate(price, timestamp, pair)
    end

    def calculate_index(price, bands)
      ((bd(price) - bands[:mean]) / (bands[:sd] * @distance)).floor.to_i
    end

    def restore_state
      @broker.positions.each do |p|
        next unless p.pair_name == @pair
        register_position(p)
      end
    end

    def register_position(position)
      bands = calculate_bollinger_bands(
        position.entry_price, position.entered_at, @pair)
      index = calculate_index(position.entry_price, bands)

      @positions[index.to_s] = Position.new(index, position)
    end

  end

  class Position

    include Utils
    attr_reader :index, :position

    def initialize(index, position)
      @index     = index
      @position  = position
    end

    def close_if_required(index)
      return false unless take_profit?(index)

      close_positions
      true
    end

    def take_profit?(index)
      if @position.sell_or_buy == :buy
        @index + 1 < index
      else
        @index - 1 > index
      end
    end

    def close_positions
      @position.close
    end

  end
end
