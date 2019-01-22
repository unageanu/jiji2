# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/model/agents/builtin_files/cross'

describe Cross do
  it 'トレンドを判定できる' do
    cross = Cross.new
    expect(cross.trend).to eq(0)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(100, 110)
    expect(result).to eq({ cross: :none, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(95, 105)
    expect(result).to eq({ cross: :none, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    # 反転したらフラグが1度だけ立つ
    result = cross.next_data(105, 100)
    expect(result).to eq({ cross: :up, trend: 1 })
    expect(cross.trend).to eq(1)
    expect(cross.cross).to eq(:up)
    expect(cross.up?).to eq(true)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(true)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(110, 105)
    expect(result).to eq({ cross: :none, trend: 1 })
    expect(cross.trend).to eq(1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(true)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(115, 110)
    expect(result).to eq({ cross: :none, trend: 1 })
    expect(cross.trend).to eq(1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(true)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    # 同じになっただけでは、クロスアップ/ダウンフラグは立たない
    result = cross.next_data(115, 115)
    expect(result).to eq({ cross: :none, trend: 0 })
    expect(cross.trend).to eq(0)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(115, 115)
    expect(result).to eq({ cross: :none, trend: 0 })
    expect(cross.trend).to eq(0)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    # 反転したタイミンクでフラグが立つ
    result = cross.next_data(115, 120)
    expect(result).to eq({ cross: :down, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:down)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(true)

    result = cross.next_data(120, 125)
    expect(result).to eq({ cross: :none, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    # 同じになって元に戻った場合
    # クロスアップフラグは立たない。
    result = cross.next_data(120, 120)
    expect(result).to eq({ cross: :none, trend: 0 })
    expect(cross.trend).to eq(0)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(115, 115)
    expect(result).to eq({ cross: :none, trend: 0 })
    expect(cross.trend).to eq(0)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(false)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)

    result = cross.next_data(120, 125)
    expect(result).to eq({ cross: :down, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:down)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(true)

    result = cross.next_data(120, 125)
    expect(result).to eq({ cross: :none, trend: -1 })
    expect(cross.trend).to eq(-1)
    expect(cross.cross).to eq(:none)
    expect(cross.up?).to eq(false)
    expect(cross.down?).to eq(true)
    expect(cross.cross_up?).to eq(false)
    expect(cross.cross_down?).to eq(false)
  end
end
