# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Model::Logging::LogData do
  include_context 'use data_builder'

  it 'LogDataを作成してログを保存できる' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))

    expect(data.backtest_id).to be nil
    expect(data.size).to eq 0
    expect(data.body.length).to eq 0

    data << 'test'
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 4
    expect(data.body.length).to eq 1

    data << 'テスト'
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 13
    expect(data.body.length).to eq 2
  end

  it 'to_hでハッシュに変換できる' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))
    data << 'test'
    data << 'テスト'

    expect(data.to_h).to eq({
      body:      "test\nテスト",
      size:      13,
      timestamp: Time.at(100)
    })
  end

  it 'サイズが100Kを超えると、full?がtrueを返す' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))
    expect(data.full?).to be false

    99.times { data << 'x' * 1024 }
    expect(data.full?).to be false

    data << 'x' * 1024
    expect(data.full?).to be true
  end

  def count
    Jiji::Model::Logging::LogData.where({ backtest_id: nil }).count
  end
end
