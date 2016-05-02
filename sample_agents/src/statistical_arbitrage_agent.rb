
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
      Property.new('trade_units', '取引数量', 10000),
      Property.new('distance',    '取引を仕掛ける間隔(sdに対する倍率)', 1)
    ]
  end

  def post_create
    graph = graph_factory.create('spread',
      :line, :last, ['#779999'])
    @trader = StatisticalArbitrage::CointegrationTrader.new(
      @trade_units.to_i, @distance.to_f, broker, graph)
  end

  def next_tick(tick)
    @trader.process_tick(tick)
  end

end

module StatisticalArbitrage

  module Utils

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
      'latest'     => { slope:0.875588818, mean:17.602128212, sd:2.218701436 }
    }

    def calculate_spread(tick, coint=resolve_coint(tick))
      aud = tick[:AUDJPY].bid
      nzd = tick[:NZDJPY].bid
      bd(aud) - (bd(nzd) * coint[:slope])
    end

    def calculate_mean(tick)
      resolve_coint(tick)[:mean]
    end

    def calculate_sd(tick)
      resolve_coint(tick)[:sd]
    end

    def resolve_coint(tick)
      key = tick.timestamp.strftime("%Y-%m-01")
      COINTEGRATIONS[key] || COINTEGRATIONS["latest"]
    end

    def bd(v)
      BigDecimal.new(v.to_f, 10)
    end

  end

  class CointegrationTrader

    include Utils

    attr :positions

    def initialize(units, distance, broker, graph=nil, logger=nil)
      @units     = units
      @distance  = distance
      @broker    = broker
      @logger    = logger
      @graph     = graph
      @positions = {}
    end

    def process_tick(tick)
      do_takeprofit(tick)
      do_trade(tick)
    end

    def do_trade(tick)
      spread = calculate_spread(tick)
      @graph << [spread.to_f.round(3)] if @graph
      @logger.info(spread.to_f.round(3)) if @logger

      coint = resolve_coint(tick)
      index = ((spread - coint[:mean]) / (coint[:sd] * @distance)).truncate.to_i
      if index != 0 && !@positions.include?(index.to_s)
        @positions[index.to_s] = create_position( index, spread, coint )
      end
    end

    def do_takeprofit(tick)
      @positions.keys.each do |key|
        @positions.delete(key) if @positions[key].close_if_required(tick)
      end
    end

    def create_position( index, spread, coint )
      index < 0 ? buy_aud(spread, coint) : sell_aud(spread, coint)
    end

    def buy_aud(spread, coint)
      buy_id  = @broker.buy(:AUDJPY, @units).trade_opened.internal_id
      sell_id = @broker.sell(:NZDJPY, @units).trade_opened.internal_id
      Position.new(:buy_aud, spread, coint, [
        @broker.positions[buy_id],
        @broker.positions[sell_id]
      ])
    end

    def sell_aud(spread, coint)
      sell_id = @broker.sell(:AUDJPY, @units).trade_opened.internal_id
      buy_id  = @broker.buy(:NZDJPY, @units).trade_opened.internal_id
      Position.new(:sell_aud, spread, coint, [
        @broker.positions[sell_id],
        @broker.positions[buy_id]
      ])
    end

  end


  class Position

    include Utils

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
      current_spread = calculate_spread(tick, @coint)
      if @trade_type == :buy_aud
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
