
require 'jiji/model/agents/agent'

# ===移動平均を使うエージェントのサンプル
# 添付ライブラリ Signals::MovingAverage を利用して移動平均を算出し、
# デッドクロスで売、ゴールデンクロスで買注文を行います。
# また、算出した移動平均値をグラフに出力します。
class MovingAverageAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
移動平均を使うエージェントです。
 -ゴールデンクロスで買い&売り建て玉をコミット。
 -デッドクロスで売り&買い建て玉をコミット。
      STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new('short', '短期移動平均線', 25),
      Property.new('long',  '長期移動平均線', 75)
    ]
  end

  def post_create
    # 移動平均の算出クラス
    # 共有ライブラリのクラスを利用。
    @mvs = [
      Signals::MovingAverage.new(@short.to_i),
      Signals::MovingAverage.new(@long.to_i)
    ]
    @cross = Cross.new

    # 移動平均グラフ
    @graph = graph_factory.create('移動平均線',
      :rate, :average, ['#779999', '#557777'])
  end

  # 次のレートを受け取る
  def next_tick(tick)
    # 移動平均を計算
    res = @mvs.map { |mv| mv.next_data(tick[:USDJPY].bid) }
    return if !res[0] || !res[1]

    # グラフに出力
    @graph << res
    # ゴールデンクロス/デッドクロスを判定
    @cross.next_data(*res)

    do_trade
  end

  def do_trade
    if @cross.cross_up?
      # ゴールデンクロス
      # 売り建玉があれば全て決済
      close_exist_positions(:sell)
      # 新規に買い
      broker.buy(:USDJPY, 1)
    elsif @cross.cross_down?
      # デッドクロス
      # 買い建玉があれば全て決済
      close_exist_positions(:buy)
      # 新規に売り
      broker.sell(:USDJPY, 1)
    end
  end

  def close_exist_positions(sell_or_buy)
    @broker.positions.each do |p|
      p.close if p.sell_or_buy == sell_or_buy
    end
  end

  # エージェントの状態を返却
  def state
    {
      mvs: @mvs.map { |mv| mv.state }
    }
  end

  # 永続化された状態から元の状態を復元する
  def restore_state(state)
    return unless state[:mvs]
    @mvs[0].restore_state(state[:mvs][0])
    @mvs[1].restore_state(state[:mvs][1])
  end

end
