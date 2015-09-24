class MovingAverageAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
移動平均を使うエージェントです。
 -ゴールデンクロスで買い&売り建て玉をコミット。
 -デッドクロスで売り&買い建て玉をコミット。
 - -1000でトレーリングストップ
      STR
  end

  # UIから設定可能なプロパティの一覧を返す。
  def self.property_infos
    [
      Property.new('short', '短期移動平均線', 25, :number),
      Property.new('long',  '長期移動平均線', 75, :number)
    ]
  end

  def post_create
    # 移動平均の算出クラス
    # 共有ライブラリのクラスを利用。(JIJI::Agent::Sharedモジュールに定義される。)
    @mvs = [
      Signals::MovingAverage.new(@short),
      Signals::MovingAverage.new(@long)
    ]
    @cross = Cross.new

    # 移動平均グラフ
    @graph = graph_factory.create('移動平均線',
      :rate, :average, '#779999', '#557777')
  end

  # 次のレートを受け取る
  def next_tick(tick)
    # 移動平均を計算
    res = @mvs.map { |mv| mv.next_data(tick[:USDJPY].bid) }

    return if  !res[0] || !res[1]

    # グラフに出力
    @graph << res

    # ゴールデンクロス/デッドクロスを判定
    @cross.next_data(*res)
    if  @cross.cross_up?
      # ゴールデンクロス
      # 売り建玉があれば全て決済
      close_exist_positions(:sell)
      # 新規に買い
      broker.buy(:USDJPY, 1)
    elsif  @cross.cross_down?
      # デッドクロス
      # 買い建玉があれば全て決済
      close_exist_positions(:buy)
      # 新規に売り
      broker.sell(:USDJPY, 1)
    end
  end

  def close_exist_positions(sell_or_buy)
    @broker.positions.each do|p|
      p.close if p.sell_or_buy == sell_or_buy
    end
  end

end

class SendNotificationAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def post_create
    notifier.compose_text_mail('foo@example.com', 'テスト', '本文')
    notifier.push_notification('テスト通知')
  end

  def next_tick(tick)
    return if @send

    notifier.compose_text_mail('foo@example.com', 'テスト2', '本文')
    notifier.push_notification('テスト通知2')
    @send = true
  end

  def execute_action(action)
    if (action == 'mail')
      notifier.compose_text_mail('foo@example.com', 'テスト2', '本文')
    else
      notifier.push_notification(action, [
        { 'label' => '通知を送る',   'action' => 'push-aaa' },
        { 'label' => '通知を送る2',  'action' => 'push-bbb' },
        { 'label' => 'メールを送る', 'action' => 'mail' }
      ])
    end
    'OK'
  end

end

class ErrorAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def post_create
  end

  def next_tick(tick)
    fail 'test.'
  end

end

class ErrorOnCreateAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def initialize
    fail 'test.'
  end

  def post_create
  end

  def next_tick(tick)
  end

end

class ErrorOnPostCreateAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def post_create
    fail 'test.'
  end

  def next_tick(tick)
  end

end
