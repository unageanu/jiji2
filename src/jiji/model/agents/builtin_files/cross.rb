
# ===交差状態を判定するユーティリティ
# 先行指標と遅行指標を受け取って、クロスアップ/クロスダウンを判定するユーティリティです。
#
#  require 'cross'
#
#  cross = Cross.new
#
#  # 先行指標、遅行指標を受け取って状態を返す。
#  # :cross .. クロスアップ、クロスダウン状態かどうかを返す。
#  #             - クロスアップ(:up)
#  #             - クロスダウン(:down)
#  #             - どちらでもない(:none)
#  # :trend .. 現在の指標が上向きか下向きかを返す。
#  #           「先行指標 <=> 遅行指標」した値。
#  #           trend >= 1なら上向き、trned <= -1なら下向き
#  p cross.next_data( 100, 90 )  # {:trend=>1, :cross=>:none}
#  p cross.next_data( 110, 100 ) # {:trend=>1, :cross=>:none}
#  p cross.next_data( 100, 100 ) # {:trend=>0, :cross=>:none}
#  p cross.next_data( 90, 100 )  # {:trend=>-1, :cross=>:down}
#  p cross.next_data( 80, 90 )   # {:trend=>-1, :cross=>:none}
#  p cross.next_data( 90, 90 )   # {:trend=>0, :cross=>:none}
#  p cross.next_data( 100, 100 ) # {:trend=>0, :cross=>:none}
#  p cross.next_data( 110, 100 ) # {:trend=>1, :cross=>:up}
#
class Cross

  # コンストラクタ
  def initialize
    @cross_prev = nil
    @cross = :none
    @trend = 0
  end

  # 次の値を渡し、状態を更新します。
  # fast:: 先行指標
  # lazy:: 遅行指標
  def next_data(fast, lazy)
    return unless fast && lazy
    # 交差状態を算出
    calculate_state(fast, lazy)
    { cross: @cross, trend: @trend }
  end

  # クロスアップ状態かどうか判定します。
  # 戻り値:: 「先行指標 < 遅行指標」 から 「先行指標 > 遅行指標」 になったらtrue
  def cross_up?
    @cross == :up
  end

  # クロスダウン状態かどうか判定します。
  # 戻り値:: 「先行指標 > 遅行指標」 から 「先行指標 < 遅行指標」 になったらtrue
  def cross_down?
    @cross == :down
  end

  # 上昇トレンド中かどうか判定します。
  # 戻り値:: 「先行指標 > 遅行指標」 ならtrue
  def up?
    @trend > 0
  end

  # 下降トレンド中かどうか判定します。
  # 戻り値:: 「先行指標 < 遅行指標」 ならtrue
  def down?
    @trend < 0
  end

  # 交差状態( :up, :down, :none )
  attr_reader :cross
  # トレンド ( 直近の falst <=> lazy 値。)
  attr_reader :trend

  private

  def calculate_state(fast, lazy)
    @trend = fast <=> lazy
    @cross = if @cross_prev && @trend != @cross_prev && @trend != 0
               @trend > @cross_prev ? :up : :down
             else
               :none
             end
    @cross_prev = @trend
  end

end
