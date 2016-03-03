
# === トレーリングストップで建玉を決済するエージェント
class TrailingStopAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
トレーリングストップで建玉を決済するエージェント。
 - 損益が警告を送る閾値を下回ったら、1度だけ警告をPush通知で送信。
 - さらに決済する閾値も下回ったら、建玉を決済します。
      STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new('warning_limit', '警告を送る閾値', 20),
      Property.new('closing_limit', '決済する閾値',   40)
    ]
  end

  def post_create
    @manager = TrailingStopManager.new(
      @warning_limit.to_i, @closing_limit.to_i, notifier)
  end

  def next_tick(tick)
    @manager.check(broker.positions, broker.pairs)
  end

  def execute_action(action)
    @manager.process_action(action, broker.positions) || '???'
  end

  def state
    {
      trailing_stop_manager: @manager.state
    }
  end

  def restore_state(state)
    if state[:trailing_stop_manager]
      @manager.restore_state(state[:trailing_stop_manager])
    end
  end

end

# 建玉を監視し、最新のレートに基づいてトレールストップを行う
class TrailingStopManager

  # コンストラクタ
  #
  # warning_limit:: 警告を送信する閾値(pip)
  # closing_limit:: 決済を行う閾値(pip)
  # notifier:: notifier
  def initialize(warning_limit, closing_limit, notifier)
    @warning_limit = warning_limit
    @closing_limit = closing_limit
    @notifier = notifier

    @states = {}
  end

  # 建玉がトレールストップの閾値に達していないかチェックする。
  # warning_limit を超えている場合、警告通知を送信、
  # closing_limit を超えた場合、強制的に決済する。
  #
  # positions:: 建て玉一覧(broker#positions)
  # pairs:: 通貨ペア一覧(broker#pairs)
  def check(positions, pairs)
    @states = positions.each_with_object({}) do |position, r|
      r[position.id.to_s] = check_position(position, pairs)
    end
  end

  # アクションを処理する
  #
  # action:: アクション
  # positions:: 建て玉一覧(broker#positions)
  # 戻り値:: アクションを処理できた場合、レスポンスメッセージ。
  #         TrailingStopManagerが管轄するアクションでない場合、nil
  def process_action(action, positions)
    return nil unless action =~ /trailing\_stop\_\_([a-z]+)_(.*)$/
    case Regexp.last_match(1)
    when 'close' then
      position = positions.find { |p| p.id.to_s == Regexp.last_match(2) }
      return nil unless position
      position.close
      return '建玉を決済しました。'
    end
  end

  # 永続化する状態。
  def state
    @states.each_with_object({}) { |s, r| r[s[0]] = s[1].state }
  end

  # 永続化された状態から、インスタンスを復元する
  def restore_state(state)
    @states = state.each_with_object({}) do |s, r|
      state = PositionState.new(nil,
        @warning_limit, @closing_limit)
      state.restore_state(s[1])
      r[s[0]] = state
    end
  end

  private

  # 建玉の状態を更新し、閾値を超えていたら対応するアクションを実行する。
  def check_position(position, pairs)
    state = get_and_update_state(position, pairs)
    if state.under_closing_limit?
      position.close
    elsif state.under_warning_limit?
      unless state.sent_warning # 通知は1度だけ送信する
        send_notification(position, state)
        state.sent_warning = true
      end
    end
    state
  end

  def get_and_update_state(position, pairs)
    state = create_or_get_state(position, pairs)
    state.update(position)
    state
  end

  def create_or_get_state(position, pairs)
    key = position.id.to_s
    return @states[key] if @states.include? key
    PositionState.new(
      retrieve_pip_for(position.pair_name, pairs),
      @warning_limit, @closing_limit)
  end

  def retrieve_pip_for(pair_name, pairs)
    pairs.find { |p| p.name == pair_name }.pip
  end

  def send_notification(position, state)
    message = create_position_description(position).to_s \
      + ' がトレールストップの閾値を下回りました。決済しますか?'
    @notifier.push_notification(message, [{
        'label'  => '決済する',
        'action' => 'trailing_stop__close_' + position.id.to_s
    }])
  end

  def create_position_description(position)
    sell_or_buy = position.sell_or_buy == :sell ? '売' : '買'
    "#{position.pair_name}/#{position.entry_price}/#{sell_or_buy}"
  end

end

class PositionState

  attr_reader :max_profit, :profit_or_loss, :max_profit_time, :last_update_time
  attr_accessor :sent_warning

  def initialize(pip, warning_limit, closing_limit)
    @pip           = pip
    @warning_limit = warning_limit
    @closing_limit = closing_limit
    @sent_warning  = false
  end

  def update(position)
    @units            = position.units
    @profit_or_loss   = position.profit_or_loss
    @last_update_time = position.updated_at

    if @max_profit.nil? || position.profit_or_loss > @max_profit
      @max_profit      = position.profit_or_loss
      @max_profit_time = position.updated_at
      @sent_warning    = false
      # 高値を更新したあと、 warning_limit を超えたら再度警告を送るようにする
    end
  end

  def under_warning_limit?
    return false if @max_profit.nil?
    difference >= @warning_limit * @units * @pip
  end

  def under_closing_limit?
    return false if @max_profit.nil?
    difference >= @closing_limit * @units * @pip
  end

  def state
    {
      'max_profit'      => @max_profit,
      'max_profit_time' => @max_profit_time,
      'pip'             => @pip,
      'sent_warning'    => @sent_warning
    }
  end

  def restore_state(state)
    @max_profit      = state['max_profit']
    @max_profit_time = state['max_profit_time']
    @pip             = state['pip']
    @sent_warning    = state['sent_warning']
  end

  private

  def difference
    @max_profit - @profit_or_loss
  end

end
