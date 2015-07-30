# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Rate do
  include_context 'use data_builder'

  it 'tickから作成できる' do
    rate1 = Jiji::Model::Trading::Rate.create_from_tick(:EURJPY,
      data_builder.new_tick(1,   Time.new(2014, 1, 1, 0, 0, 0)),
      data_builder.new_tick(2,   Time.new(2014, 2, 1, 0, 0, 0)),
      data_builder.new_tick(3,   Time.new(2014, 1, 1, 0, 0, 1)),
      data_builder.new_tick(10,  Time.new(2014, 1, 10, 0, 0, 0)),
      data_builder.new_tick(-10, Time.new(2014, 1, 21, 0, 0, 0))
    )

    expect(rate1.pair).to eq(:EURJPY)
    expect(rate1.open.bid).to eq(101)
    expect(rate1.open.ask).to eq(101.003)
    expect(rate1.close.bid).to eq(102)
    expect(rate1.close.ask).to eq(102.003)
    expect(rate1.high.bid).to eq(110)
    expect(rate1.high.ask).to eq(110.003)
    expect(rate1.low.bid).to eq(90)
    expect(rate1.low.ask).to eq(90.003)
    expect(rate1.timestamp).to eq(Time.new(2014, 1, 1, 0, 0, 0))
  end

  it 'すべての値が同一である場合、同一とみなされる' do
    rate1 = data_builder.new_rate(1)
    rate2 = data_builder.new_rate(2)

    expect(rate1 == rate2).to eq(false)
    expect(rate1 == data_builder.new_rate(1)).to eq(true)

    expect(rate1.eql?(rate2)).to eq(false)
    expect(rate1.eql?(rate1)).to eq(true)
    expect(rate1.eql?(data_builder.new_rate(1))).to eq(true)

    expect(rate1.equal?(rate2)).to eq(false)
    expect(rate1.equal?(rate1)).to eq(true)
    expect(rate1.equal?(data_builder.new_rate(1))).to eq(false)
  end

  it 'clone で複製ができる' do
    rate1 = data_builder.new_rate(1)
    clone = rate1.clone

    expect(rate1 == clone).to eq(true)
    expect(rate1.eql?(clone)).to eq(true)
    expect(rate1.equal?(clone)).to eq(false)
  end

  it 'unionで統合できる' do
    rate1 = Jiji::Model::Trading::Rate.create_from_tick(:USDJPY,
      data_builder.new_tick(1,   Time.new(2014, 1, 3, 0, 0, 0)),
      data_builder.new_tick(2,   Time.new(2014, 2, 1, 0, 0, 0))
    )
    rate2 = Jiji::Model::Trading::Rate.create_from_tick(:USDJPY,
      data_builder.new_tick(4,   Time.new(2014, 1, 1, 0, 0, 0)),
      data_builder.new_tick(5,   Time.new(2014, 1, 2, 0, 0, 0))
    )
    rate3 = Jiji::Model::Trading::Rate.create_from_tick(:USDJPY,
      data_builder.new_tick(6,   Time.new(2014, 4, 3, 0, 0, 0)),
      data_builder.new_tick(7,   Time.new(2014, 3, 1, 0, 0, 0))
    )

    rate = Jiji::Model::Trading::Rate.union(rate1, rate2, rate3)
    expect(rate.pair).to eq(:USDJPY)
    expect(rate.open.bid).to eq(104)
    expect(rate.open.ask).to eq(104.003)
    expect(rate.close.bid).to eq(106)
    expect(rate.close.ask).to eq(106.003)
    expect(rate.high.bid).to eq(107)
    expect(rate.high.ask).to eq(107.003)
    expect(rate.low.bid).to eq(101)
    expect(rate.low.ask).to eq(101.003)
    expect(rate.timestamp).to eq(Time.new(2014, 1, 1, 0, 0, 0))
  end
end
