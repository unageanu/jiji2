require 'quandl'
require 'lru_redux'

# === 統計的裁定取引エージェント
class StatisticalArbitrageAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
      統計的裁定取引エージェント
    STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new('pairs',          '対象通貨(カンマ区切り)', 'AUD,NZD,CAD'),
      Property.new('trade_units',    '取引数量', 10_000),
      Property.new('distance',       '取引を仕掛ける間隔(sdに対する倍率)', 1),
      Property.new('quandl_api_key', 'Quandl API KEY', '')
    ]
  end

  def post_create
    @max_dd = 0
    @spread_graph = graph_factory.create('spread',
      :line, :last, ['#779999', '#997799', '#999977'])

    resolver = create_resolver
    @traders = create_pairs.each_with_object({}) do |pairs, r|
      trader = StatisticalArbitrage::CointegrationTrader.new(pairs[0].to_sym,
        pairs[1].to_sym, @trade_units.to_i, @distance.to_f, broker, logger)
      trader.cointegration_resolver = resolver
      r[pairs.join()] = trader
    end
  end

  def next_tick(tick)
    @spread_graph << @traders.values.map do |trader|
      trader.process_tick(tick)
    end
    print_total_profit_or_loss(tick)
  end

  def print_total_profit_or_loss(tick)
    total_profit_or_loss = broker.positions.sum(&:profit_or_loss) || 0
    @max_dd = total_profit_or_loss < @max_dd ? total_profit_or_loss : @max_dd
    @logger.info("#{tick.timestamp} #{total_profit_or_loss} #{@max_dd}")
  end

  def create_resolver
    if !@quandl_api_key.nil? && !@quandl_api_key.empty?
      StatisticalArbitrage::QuandlResolver.new(@quandl_api_key)
    else
      StatisticalArbitrage::StaticConstantsResolver.new
    end
  end

  def save_state
    @traders.keys.each_with_object({}) do |k, r|
      r[k] = @traders[k].save_state
    end
  end

  def restore_state(state)
    state.each do |pair|
      if @traders[pair[0]]
        @traders[pair[0]].restore_state(pair[1])
      else
        logger.warn "failed to restore state : unknown pair #{pair[0]}"
      end
    end
  end

  def create_pairs
    @pairs.split(",").combination(2).map do |pair|
      pair.map {|p| (p + "JPY").to_sym }
    end
  end

end

module StatisticalArbitrage
  module Utils
    def calculate_spread(pair1, pair2, tick, coint)
      price1 = tick[pair1].bid
      price2 = tick[pair2].bid
      calculate_spread_from_price(price1, price2, coint)
    end

    def calculate_spread_from_price(price1, price2, coint)
      bd(price1) - (bd(price2) * coint[:slope])
    end

    def resolve_coint(time, pair1, pair2)
      @cointegration_resolver.resolve(time, pair1, pair2)
    end

    def calculate_index(spread, coint, distance)
      ((spread - coint[:mean]) / (coint[:sd] * distance)).floor.to_i
    end

    def bd(v)
      BigDecimal(v.to_f, 10)
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


  class CointegrationTrader

    include Utils

    attr_reader :positions
    attr_writer :cointegration_resolver

    def initialize(pair1, pair2, units, distance, broker, logger = nil,
      resolver = StatisticalArbitrage::StaticConstantsResolver.new)
      @pair1         = pair1
      @pair2         = pair2
      @units         = units
      @distance      = distance
      @broker        = broker
      @logger        = logger

      @cointegration_resolver = resolver
      @positions = {}
    end

    def process_tick(tick)
      coint = resolve_coint(tick.timestamp, @pair1, @pair2)
      spread = calculate_spread(@pair1, @pair2, tick, coint)
      index = calculate_index(spread, coint)

      do_takeprofit(index)
      do_trade(tick, coint, spread, index)
      spread.to_f.round(3)
    end

    def do_trade(tick, coint, spread, index)
      log(spread, tick, coint, index)

      if index.nonzero? && index != -1 && !@positions.include?(index.to_s)
        @positions[index.to_s] = create_position(index, spread, coint)
      end
    end

    def log(spread, tick, coint, index)
      return unless @logger
      ratio = ((spread - coint[:mean]) / (coint[:sd] * @distance)).round(3)
      @logger.info(
        "#{tick.timestamp} #{@pair1} #{@pair2} #{tick[@pair1].bid} #{tick[@pair2].bid}" \
      + " #{spread.to_f.round(3)} #{@distance} " \
      + " #{coint[:slope]} #{index} #{coint[:sd]} #{coint[:mean]} #{ratio}")
    end

    def do_takeprofit(index)
      @positions.keys.each do |key|
        @positions.delete(key) if @positions[key].close_if_required(index)
      end
    end

    def create_position(index, spread, coint)
      index < 0 ? buy_a(spread, coint, index) : sell_a(spread, coint, index)
    end

    def buy_a(spread, coint, index)
      pair2_units = calculate_units(coint)
      @broker.buy(@pair1, @units)
      @broker.sell(@pair2, pair2_units)
      @logger.info("** buy_a : #{@units} #{pair2_units}") if @logger
      Position.new(:buy_a, [
        {"pair" => @pair1, "units" => @units,      "sell_or_buy" => :buy},
        {"pair" => @pair2, "units" => pair2_units, "sell_or_buy" => :sell}
      ], index, @broker)
    end

    def sell_a(spread, coint, index)
      pair2_units = calculate_units(coint)
      @broker.sell(@pair1, @units)
      @broker.buy(@pair2, pair2_units)
      @logger.info("** sell_a : #{@units} #{pair2_units}") if @logger
      Position.new(:sell_a, [
        {"pair" => @pair1, "units" => @units,      "sell_or_buy" => :sell},
        {"pair" => @pair2, "units" => pair2_units, "sell_or_buy" => :buy}
      ], index, @broker)
    end

    def calculate_units(coint)
      (@units * coint[:slope]).round
    end

    def calculate_index(spread, coint)
      ((spread - coint[:mean]) / (coint[:sd] * @distance)).floor.to_i
    end

    def save_state
      @positions.values.map { |v| v.to_hash }
    end

    def restore_state(state)
      state.each do |s|
        position = Position.from_hash(s)
        position.broker = @broker
        @positions[position.index.to_s] = position
      end
      @logger.info(@positions.keys) if @logger
    end

  end

  class Position

    include Utils
    attr_reader :trade_type, :index, :positions
    attr_writer :broker

    def initialize(trade_type, positions, index, broker=nil)
      @trade_type = trade_type
      @index      = index
      @positions  = positions
      @broker     = broker
    end

    def close_if_required(index)
      return false unless take_profit?(index)

      close_positions
      true
    end

    def take_profit?(index)
      if @trade_type == :buy_a
        @index + 1 < index
      else
        @index - 1 > index
      end
    end

    def close_positions
      @positions.each do |p|
        if p["sell_or_buy"] == :sell
          @broker.buy(p["pair"], p["units"])
        else
          @broker.sell(p["pair"], p["units"])
        end
      end
    end

    def self.from_hash(hash)
      Position.new(
        hash["trade_type"].to_sym,
        hash["positions"],
        hash["index"].to_i)
    end

    def to_hash
      {
        "trade_type" => @trade_type,
        "index" => @index,
        "positions" => @positions
      }
    end

  end


  class CointegrationResolver

    def resolve(time)
    end

  end

  class QuandlResolver

    include Utils

    def initialize(api_key)
      Quandl::ApiConfig.api_key = api_key if api_key
      Quandl::ApiConfig.api_version = '2015-04-09'

      @cache = LruRedux::ThreadSafeCache.new(10)
    end

    def resolve(time, pair1, pair2)
      key = time.strftime('%Y-%m-%d')
      @cache[key] || (@cache[key] = calculate_cointegration(time, pair1, pair2))
    end

    def calculate_cointegration(time, pair1, pair2)
      rates = retrieve_rates(time, pair1, pair2)
      linner_least_squares = linner_least_squares(rates)
      spread = calculate_spread(rates, linner_least_squares)
      {
        slope: linner_least_squares[0].to_f.round(9),
        mean:  mean(spread).to_f.round(9),
        sd:    standard_deviation(spread).to_f.round(9)
      }
    end

    def calculate_spread(rates, linner_least_squares)
      rates.map do |rate|
        bd(rate[0]) - bd(rate[1]) * linner_least_squares[0]
      end
    end

    def linner_least_squares(rates)
      a = b = c = d = BigDecimal(0.0, 15)
      rates.each do |r|
        x = r[0]
        y = r[1]
        a += x * y
        b += x
        c += y
        d += x**2
      end
      n = rates.size
      [(n * a - b * c) / (n * d - b**2), (d * c - a * b) / (n * d - b**2)]
    end

    def retrieve_rates(time, pair1, pair2)
      rates1 = retrieve_rates_from_quandl(time, pair1)
      rates2 = retrieve_rates_from_quandl(time, pair2)
      merged = {}
      rates1.each { |rate| merged[rate['date']] = [rate['rate']] unless rate['rate'].nil? }
      rates2.each do |rate|
        merged[rate['date']] << rate['rate'] if merged.include?(rate['date'])
      end
      merged.values.reject { |d| d.length < 2 }
    end

    def retrieve_rates_from_quandl(time, pair)
      Quandl::Dataset.get("CURRFX/#{pair}")
        .data(params: {
          rows:       1000,
          start_date: (time - 2 * 365 * 24 * 60 * 60).strftime('%Y-%m-%d'),
          end_date:   time.strftime('%Y-%m-%d')
        })
    end

  end

  class StaticConstantsResolver

    COINTEGRATIONS = {
      '2014-01' => { slope: 0.639779926, mean: 39.798570231, sd: 1.118107989 },
      '2014-02' => { slope: 0.472707933, mean: 53.086706403, sd: 1.410627152 },
      '2014-03' => { slope: 0.434243152, mean: 56.061332315, sd: 1.426766217 },
      '2014-04' => { slope: 0.388503806, mean: 59.716515347, sd: 1.417530649 },
      '2014-05' => { slope: 0.452009838, mean: 54.565881819, sd: 1.400824698 },
      '2014-06' => { slope: 0.468971690, mean: 53.195204405, sd: 1.345733500 },
      '2014-07' => { slope: 0.495815150, mean: 51.029449076, sd: 1.323011803 },
      '2014-08' => { slope: 0.507880741, mean: 50.059333184, sd: 1.289276140 },
      '2014-09' => { slope: 0.528603160, mean: 48.425611954, sd: 1.328614653 },
      '2014-10' => { slope: 0.565019583, mean: 45.504254407, sd: 1.441246028 },
      '2014-11' => { slope: 0.565114069, mean: 45.575041006, sd: 1.435544728 },
      '2014-12' => { slope: 0.658238976, mean: 37.829951061, sd: 1.591378385 },
      '2015-01' => { slope: 0.648219391, mean: 38.666538200, sd: 1.580403641 },
      '2015-02' => { slope: 0.621887956, mean: 40.839250260, sd: 1.587189027 },
      '2015-03' => { slope: 0.599479337, mean: 42.612445521, sd: 1.702255585 },
      '2015-04' => { slope: 0.557575116, mean: 46.056167220, sd: 1.819182217 },
      '2015-05' => { slope: 0.503979842, mean: 50.493955291, sd: 1.998065715 },
      '2015-06' => { slope: 0.500765214, mean: 50.761523621, sd: 1.961816777 },
      '2015-07' => { slope: 0.497107112, mean: 51.135469439, sd: 1.943820297 },
      '2015-08' => { slope: 0.503640515, mean: 50.550317504, sd: 1.923043502 },
      '2015-09' => { slope: 0.501153345, mean: 50.760732076, sd: 1.951388645 },
      '2015-10' => { slope: 0.628108957, mean: 39.577199938, sd: 2.051391140 },
      '2015-11' => { slope: 0.711480649, mean: 32.131315959, sd: 2.077261234 },
      '2015-12' => { slope: 0.759938317, mean: 27.773159032, sd: 2.049069654 },
      '2016-01' => { slope: 0.782435872, mean: 25.723287669, sd: 2.088435715 },
      '2016-02' => { slope: 0.837360002, mean: 20.909344389, sd: 2.163306779 },
      '2016-03' => { slope: 0.879965684, mean: 17.162602491, sd: 2.221233518 },
      '2016-04' => { slope: 0.875588818, mean: 17.602128212, sd: 2.218701436 },
      '2016-05' => { slope: 0.870884249, mean: 17.985573263, sd: 2.223409486 },
      'latest'  => { slope: 0.870884249, mean: 17.985573263, sd: 2.223409486 }
    }.freeze

    def resolve(time, pair1, pair2)
        key = time.strftime('%Y-%m')
        COINTEGRATIONS[key] || COINTEGRATIONS['latest']
    end
  end

end
