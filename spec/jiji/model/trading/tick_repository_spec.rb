# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::TickRepository do
  include_context 'use container'
  let(:repository) { container.lookup(:tick_repository) }

  it 'fetch で tickの一覧を取得できる' do
    ticks = repository.fetch([:EURJPY, :USDJPY], Time.at(0), Time.at(75))

    expect(ticks.length).to eq(5)
    expect(ticks[0][:EURJPY].bid).to eq(135.3)
    expect(ticks[0][:EURJPY].ask).to eq(135.33)
    expect(ticks[0].timestamp).to eq(Time.at(0))

    expect(ticks[1][:EURJPY].bid).to eq(135.56)
    expect(ticks[1][:EURJPY].ask).to eq(135.59)
    expect(ticks[1].timestamp).to eq(Time.at(15))

    expect(ticks[4][:EURJPY].bid).to eq(135.601)
    expect(ticks[4][:EURJPY].ask).to eq(135.631)
    expect(ticks[4].timestamp).to eq(Time.at(60))

    expect(ticks[0][:USDJPY].bid).to eq(112.1)
    expect(ticks[0][:USDJPY].ask).to eq(112.12)
    expect(ticks[0].timestamp).to eq(Time.at(0))

    expect(ticks[1][:USDJPY].bid).to eq(112.36)
    expect(ticks[1][:USDJPY].ask).to eq(112.38)
    expect(ticks[1].timestamp).to eq(Time.at(15))

    expect(ticks[4][:USDJPY].bid).to eq(112.401)
    expect(ticks[4][:USDJPY].ask).to eq(112.421)
    expect(ticks[4].timestamp).to eq(Time.at(60))

    ticks = repository.fetch([:EURJPY], Time.at(30), Time.at(90))

    expect(ticks.length).to eq(4)
    expect(ticks[0][:EURJPY].bid).to eq(135.3)
    expect(ticks[0][:EURJPY].ask).to eq(135.33)
    expect(ticks[0].timestamp).to eq(Time.at(30))

    expect(ticks[3][:EURJPY].bid).to eq(135.603)
    expect(ticks[3][:EURJPY].ask).to eq(135.633)
    expect(ticks[3].timestamp).to eq(Time.at(75))


    ticks = repository.fetch([:EURJPY, :USDJPY],
      Time.at(0), Time.at(60*60*9 + 10), :one_hour)
    expect(ticks.length).to eq(10)
    expect(ticks[0][:EURJPY].bid).to eq(135.3)
    expect(ticks[0][:EURJPY].ask).to eq(135.33)
    expect(ticks[0].timestamp).to eq(Time.at(0))

    expect(ticks[9][:EURJPY].bid).to eq(135.5)
    expect(ticks[9][:EURJPY].ask).to eq(135.53)
    expect(ticks[9].timestamp).to eq(Time.at(60*60*9))
  end

  it 'range で tickが登録されている期間を取得できる' do
    range = repository.range

    expect(range[:start]).not_to be nil
    expect(range[:end]).not_to be nil
  end
end
