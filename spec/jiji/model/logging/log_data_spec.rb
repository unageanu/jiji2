# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Logging::LogData do

  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end

  after(:example) do
    @data_builder.clean
  end

  it 'LogDataを作成してログを保存できる' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))

    expect(data.backtest_id).to be nil
    expect(data.size).to eq 0
    expect(data.body.length).to eq 0

    data << "test"
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 4
    expect(data.body.length).to eq 1

    data << "テスト"
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 13
    expect(data.body.length).to eq 2
  end

  it 'to_hでハッシュに変換できる' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))
    data << "test"
    data << "テスト"

    expect(data.to_h).to eq({
      body: "test\nテスト",
      size: 13,
      timestamp: Time.at(100)
    })
  end

  it 'サイズが既定値を超えると、自動保存される' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))
    expect(count).to be 0

    data << "x"*1024
    expect(count).to be 0

    data << "x"*1024
    expect(count).to be 0

    7.times { data << "x"*1024 }
    expect(count).to be 0

    data << "x"*1024
    expect(count).to be 1

    loaded = Jiji::Model::Logging::LogData.find(data._id)
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 10 * 1024
    expect(data.body.length).to eq 10
  end

  it 'サイズが500Kを超えると、full?がtrueを返す' do
    data = Jiji::Model::Logging::LogData.create(Time.at(100))
    expect(data.full?).to be false

    499.times { data << "x"*1024 }
    expect(data.full?).to be false

    data << "x"*1024
    expect(data.full?).to be true

    loaded = Jiji::Model::Logging::LogData.find(data._id)
    expect(data.backtest_id).to be nil
    expect(data.size).to eq 500 * 1024
    expect(data.body.length).to eq 500
  end

  def count
    Jiji::Model::Logging::LogData.where({backtest_id: nil}).count
  end

end
