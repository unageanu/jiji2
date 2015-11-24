class RestartTestAgent

  include Jiji::Model::Agents::Agent

  def next_tick(tick)
    account = broker.account

    puts '---'
    puts "#{tick[:USDJPY].bid} #{tick.timestamp}"
    puts "#{account.balance} #{account.profit_or_loss}"
    puts "#{broker.positions.map { |p| p.units }} "
    puts "#{broker.orders.map { |p| p.units }}"
    puts "#{@a} #{@b}"

    @current_tick = tick
    @a += 1
    @b += 1
  end

  def state
    { a: @a }
  end

  def restore_state(state)
    puts "restore_state #{state}"
    @a = state[:a]
  end

  def execute_action(action)
    if (action == 'order')
      do_order
    elsif (action == 'close')
      broker.positions.each { |p| p.close }
    elsif (action == 'cancel_orders')
      broker.orders.each { |o| o.cancel }
    end
    'OK'
  end

  attr_reader :a, :b

  def do_order
    base_price  = @current_tick[:USDJPY].bid
    base_price2 = @current_tick[:EURJPY].bid

    # EURJPYを10000単位、成行で売り
    broker.sell(:USDJPY, 10_000)
    # 各種オプションを指定して、EURJPYを10000単位、成行で買い
    broker.buy(:EURJPY,  10_001, :market, {
      lower_bound:   base_price2 - 1,  # 成立下限価格
      upper_bound:   base_price2 + 1,  # 成立上限価格

      # 建玉の約定条件
      stop_loss:     base_price2 - 5,  # ストップロス価格
      take_profit:   base_price2 + 5,  # テイクプロフィット価格
      trailing_stop: 1000       # トレーリングストップのディスタンスをpipsで指定します。
    })

    # 指値135.6で売り注文
    broker.sell(:USDJPY, 10_002, :limit, {
      price:  base_price + 0.5,
      expiry: @current_tick.timestamp + 60 * 60 * 24  # 注文の有効期限
    })

    # 逆指値112.404で買い注文
    broker.buy(:EURJPY, 10_003, :stop, {
      price:         base_price2 + 0.5,
      expiry:        @current_tick.timestamp + 60 * 60 * 24,

      # lower_bound等のオプションは、注文方法によらず指定可能です。
      lower_bound:   base_price2 - 1,
      upper_bound:   base_price2 + 1,
      stop_loss:     base_price2 - 5,
      take_profit:   base_price2 + 5,
      trailing_stop: 2000
    })

    # Market If Touched で買い
    broker.buy(:EURJPY, 10_004, :marketIfTouched, {
      price:  base_price2 - 0.5,
      expiry: @current_tick.timestamp + 60 * 60 * 24
    })
  end

end
