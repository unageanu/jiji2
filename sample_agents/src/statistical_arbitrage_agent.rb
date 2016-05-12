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
      Property.new('pair1',          '通貨ペア1', "AUDJPY"),
      Property.new('pair2',          '通貨ペア2', "NZDJPY"),
      Property.new('trade_units',    '取引数量', 10000),
      Property.new('distance',       '取引を仕掛ける間隔(sdに対する倍率)', 1),
      Property.new('quandl_api_key', 'Quandl API KEY', ''),
    ]
  end

  def post_create
    spread_graph = graph_factory.create('spread',
      :line, :last, ['#779999'])
    rate_graph = graph_factory.create('rate',
      :rate, :last, ['#FF6633', '#FFAA22'])

    @trader = StatisticalArbitrage::CointegrationTrader.new(
      @pair1.to_sym, @pair2.to_sym, @trade_units.to_i, @distance.to_f,
      broker, spread_graph, rate_graph, logger)

    if @quandl_api_key.nil? && @quandl_api_key.length > 0
      @trader.cointegration_resolver =
        StatisticalArbitrage::QuandlResolver.new(@quandl_api_key)
    end
  end

  def next_tick(tick)
    @trader.process_tick(tick)
  end

end

module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation
      return Math.sqrt(self.sample_variance)
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

    def bd(v)
      BigDecimal.new(v.to_f, 10)
    end

  end

  class CointegrationResolver
    def resolve(time)
    end
  end

  class StaticConstantsResolver

    COINTEGRATIONS = {
      '2014-01-01' => { slope:0.639779926, mean:39.798570231, sd:1.118107989 },
      '2014-02-01' => { slope:0.472707933, mean:53.086706403, sd:1.410627152 },
      '2014-03-01' => { slope:0.434243152, mean:56.061332315, sd:1.426766217 },
      '2014-04-01' => { slope:0.388503806, mean:59.716515347, sd:1.417530649 },
      '2014-05-01' => { slope:0.452009838, mean:54.565881819, sd:1.400824698 },
      '2014-06-01' => { slope:0.468971690, mean:53.195204405, sd:1.345733500 },
      '2014-07-01' => { slope:0.495815150, mean:51.029449076, sd:1.323011803 },
      '2014-08-01' => { slope:0.507880741, mean:50.059333184, sd:1.289276140 },
      '2014-09-01' => { slope:0.528603160, mean:48.425611954, sd:1.328614653 },
      '2014-10-01' => { slope:0.565019583, mean:45.504254407, sd:1.441246028 },
      '2014-11-01' => { slope:0.565114069, mean:45.575041006, sd:1.435544728 },
      '2014-12-01' => { slope:0.658238976, mean:37.829951061, sd:1.591378385 },
      '2015-01-01' => { slope:0.648219391, mean:38.666538200, sd:1.580403641 },
      '2015-02-01' => { slope:0.621887956, mean:40.839250260, sd:1.587189027 },
      '2015-03-01' => { slope:0.599479337, mean:42.612445521, sd:1.702255585 },
      '2015-04-01' => { slope:0.557575116, mean:46.056167220, sd:1.819182217 },
      '2015-05-01' => { slope:0.503979842, mean:50.493955291, sd:1.998065715 },
      '2015-06-01' => { slope:0.500765214, mean:50.761523621, sd:1.961816777 },
      '2015-07-01' => { slope:0.497107112, mean:51.135469439, sd:1.943820297 },
      '2015-08-01' => { slope:0.503640515, mean:50.550317504, sd:1.923043502 },
      '2015-09-01' => { slope:0.501153345, mean:50.760732076, sd:1.951388645 },
      '2015-10-01' => { slope:0.628108957, mean:39.577199938, sd:2.051391140 },
      '2015-11-01' => { slope:0.711480649, mean:32.131315959, sd:2.077261234 },
      '2015-12-01' => { slope:0.759938317, mean:27.773159032, sd:2.049069654 },
      '2016-01-01' => { slope:0.782435872, mean:25.723287669, sd:2.088435715 },
      '2016-02-01' => { slope:0.837360002, mean:20.909344389, sd:2.163306779 },
      '2016-03-01' => { slope:0.879965684, mean:17.162602491, sd:2.221233518 },
      '2016-04-01' => { slope:0.875588818, mean:17.602128212, sd:2.218701436 },
      '2016-05-01' => { slope:0.870884249, mean:17.985573263, sd:2.223409486 },
      'latest'     => { slope:0.870884249, mean:17.985573263, sd:2.223409486 }
    }

    def resolve(time, pair1, pair2)
      key = time.strftime("%Y-%m-01")
      COINTEGRATIONS[key] || COINTEGRATIONS["latest"]
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
      key = time.strftime("%Y-%m-%d")
      @cache[key] || (@cache[key] = calculate_cointegration(time, pair1, pair2))
    end

    def calculate_cointegration(time, pair1, pair2)
      rates = retrieve_rates(time, pair1, pair2)
      linner_least_squares = linner_least_squares(rates)
      spread = calculate_spread(rates, linner_least_squares)
      return {
        slope: linner_least_squares[0].to_f.round(9),
        mean: spread.mean.to_f.round(9),
        sd: spread.standard_deviation.to_f.round(9)
      }
    end

    def calculate_spread(rates, linner_least_squares)
      rates.map do |rate|
        bd(rate[0]) - bd(rate[1]) * linner_least_squares[0]
      end
    end

    def linner_least_squares(rates)
      a = b = c = d = BigDecimal.new(0.0, 15)
      rates.each do |r|
        x = r[0]
        y = r[1]
        a += x*y
        b += x
        c += y
        d += x**2
      end
      n = rates.size
      return [(n*a-b*c)/(n*d-b**2),  (d*c-a*b)/(n*d-b**2)]
    end

    def retrieve_rates(time, pair1, pair2)
      rates1 = retrieve_rates_from_quandl(time, pair1)
      rates2 = retrieve_rates_from_quandl(time, pair2)
      merged = {}
      rates1.each {|rate| merged[rate["date"]] = [rate["rate"]] }
      rates2.each do |rate|
        merged[rate["date"]] << rate["rate"] if merged.include?(rate["date"])
      end
      return merged.values.reject {|d| d.length < 2 }
    end

    def retrieve_rates_from_quandl(time, pair)
      Quandl::Dataset.get("CURRFX/#{pair.to_s}")
        .data(params: {
          rows: 1000,
          start_date: (time - 2*365*24*60*60).strftime("%Y-%m-%d"),
          end_date: time.strftime("%Y-%m-%d")
        })
    end

  end

  class CointegrationTrader

    include Utils

    attr :positions
    attr_writer :cointegration_resolver

    def initialize(pair1, pair2, units, distance, broker,
      spread_graph=nil, rate_graph=nil, logger=nil)
      @pair1         = pair1
      @pair2         = pair2
      @units         = units
      @distance      = distance
      @broker        = broker
      @logger        = logger
      @spread_graph  = spread_graph
      @rate_graph    = rate_graph

      @cointegration_resolver = StaticConstantsResolver.new
      @positions = {}

      restore_state
    end

    def process_tick(tick)
      do_takeprofit(tick)
      do_trade(tick)
    end

    def do_trade(tick)
      coint = resolve_coint(tick.timestamp, @pair1, @pair2)
      spread = calculate_spread(@pair1, @pair2, tick, coint)
      index = calculate_index(spread, coint)

      register_graph_data(spread, tick, coint)
      log(spread, tick, coint)

      if index != 0 && !@positions.include?(index.to_s)
        @positions[index.to_s] = create_position( index, spread, coint )
      end
    end

    def register_graph_data(spread, tick, coint)
      @spread_graph << [spread.to_f.round(3)] if @spread_graph

      pair2_price = (tick[@pair2].bid * coint[:slope]) + coint[:mean]
      @rate_graph   << [tick[@pair1].bid, pair2_price] if @rate_graph
    end

    def log(spread, tick, coint)
      return unless @logger
      @logger.info(
         "#{tick.timestamp} #{tick[@pair1].bid} #{tick[@pair2].bid}" \
       + " #{spread.to_f.round(3)} #{@distance} " \
       + " #{coint[:sd]} #{coint[:mean]} #{index}")
    end

    def do_takeprofit(tick)
      @positions.keys.each do |key|
        @positions.delete(key) if @positions[key].close_if_required(tick)
      end
    end

    def create_position( index, spread, coint )
      index < 0 ? buy_a(spread, coint) : sell_a(spread, coint)
    end

    def buy_a(spread, coint)
      buy_position  = @broker.buy(@pair1, @units).trade_opened
      sell_position = @broker.sell(@pair2, units_for_pair2(coint)).trade_opened
      Position.new(:buy_a, spread, coint, [
        @broker.positions[buy_position.internal_id],
        @broker.positions[sell_position.internal_id]
      ], @distance)
    end

    def sell_a(spread, coint)
      sell_position = @broker.sell(@pair1, @units).trade_opened
      buy_position  = @broker.buy(@pair2, units_for_pair2(coint)).trade_opened
      Position.new(:sell_a, spread, coint, [
        @broker.positions[sell_position.internal_id],
        @broker.positions[buy_position.internal_id]
      ], @distance)
    end

    def units_for_pair2(coint)
      (@units*coint[:slope]).round
    end

    def calculate_index(spread, coint)
      ((spread - coint[:mean]) / (coint[:sd] * @distance)).truncate.to_i
    end

    def restore_state
      @broker.positions.each do |p|
        next unless p.pair_name == @pair1

        pair_position = find_pair_position( @broker.positions, p )
        next unless pair_position

        register_position(p, pair_position)
      end
    end

    def find_pair_position( positions, position )
      positions.find do |p|
        p.pair_name == @pair2 \
        && p.sell_or_buy == (position.sell_or_buy == :sell ? :buy : :sell) \
        && (p.entered_at.to_i - position.entered_at.to_i).abs <= 30
      end
    end

    def register_position(position1, position2)
      trade_type = position1.sell_or_buy == :sell ? :sell_a : :buy_a
      coint = resolve_coint(position1.entered_at, @pair1, @pair2)
      spread = calculate_spread_from_price(
        position1.entry_price, position2.entry_price, coint)
      index = calculate_index(spread, coint)
      return if @positions.include? index.to_s

      @positions[index.to_s] = Position.new(trade_type, spread, coint, [
        position1, position2
      ], @distance)
    end

  end


  class Position

    include Utils
    attr :trade_type, :spread, :coint, :positions, :distance

    def initialize( trade_type, spread, coint, positions, distance = 1 )
      @trade_type = trade_type
      @spread     = spread
      @coint      = coint
      @positions  = positions
      @distance   = distance
    end

    def close_if_required(tick)
      return false unless take_profit?(tick)

      close_positions
      return true
    end

    def take_profit?(tick)
      current_spread = calculate_spread(
        @positions[0].pair_name, @positions[1].pair_name, tick, @coint)
      if @trade_type == :buy_a
        current_spread >= @spread + @coint[:sd] * @distance
      else
        current_spread <= @spread - @coint[:sd] * @distance
      end
    end

    def close_positions
      @positions.each { |p| p.close }
    end

  end

end
