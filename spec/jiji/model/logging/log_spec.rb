# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'logger'

describe Jiji::Model::Logging::Log do

  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:time_source) { Jiji::Utils::TimeSource.new }

  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container}
  let(:backtest) do
     agent_registry      = container.lookup(:agent_registry)
     backtest_repository = container.lookup(:backtest_repository)
     agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    data_builder.register_backtest(1, backtest_repository)
  end

  let(:log) { Jiji::Model::Logging::Log.new(time_source)}
  let(:backtest_log) { Jiji::Model::Logging::Log.new(time_source, backtest)}
  let(:logger) { Logger.new(log) }
  let(:backtest_logger) { Logger.new(backtest_log) }

  after(:example) do
    data_builder.clean
  end

  it 'ログを保存できる' do
    time_source.set(Time.at(100))

    logger.warn("test")
    logger.error(StandardError.new("test"))
    logger.close

    expect(log.count).to be 1
    log_data = log.get(0)
    expect(log_data.size).to be > 0
    expect(log_data.timestamp).to eq Time.at(100)
    expect(log_data.body.length).to be > 0
    expect(log_data.to_h[:body]).not_to be nil
    puts log_data.to_h[:body]
  end

  it '500kを超えると、別のデータに分割される' do

    1001.times do |i|
      time_source.set(Time.at(i*100))
      logger.info("x"*1024)
    end

    expect(log.count).to be 3
    log.each do |log_data|
      expect(log_data.size).to be > 0
      expect(log_data.timestamp).not_to be nil
      expect(log_data.body.length).to be > 0
      expect(log_data.to_h[:body]).not_to be nil
    end
  end

  describe '#get' do
    it '指定したインデックスのログデータを取得できる' do

      11.times do |i|
        time_source.set(Time.at(i*100))
        logger.info("x"*1024*100)
      end

      expect(log.count).to be 3
      log_data = log.get(0)
      expect(log_data.timestamp).to eq Time.at(0)
      log_data = log.get(1)
      expect(log_data.timestamp).to eq Time.at(4*100)
      log_data = log.get(2)
      expect(log_data.timestamp).to eq Time.at(9*100)

      log_data = log.get(0, :desc)
      expect(log_data.timestamp).to eq Time.at(9*100)
      log_data = log.get(1, :desc)
      expect(log_data.timestamp).to eq Time.at(4*100)
      log_data = log.get(2, :desc)
      expect(log_data.timestamp).to eq Time.at(0)
    end

    it '不正なindexを指定した場合、nullが返される' do
      log_data = log.get(0)
      expect(log.get(0)).to  be nil
      expect(log.get(1)).to  be nil
      expect(log.get(-1)).to  be nil
    end
  end

  it 'delete_before で指定日時より前のログを削除できる' do

    11.times do |i|
      time_source.set(Time.at(i*100))
      logger.info("x"*1024*100)
    end
    expect(log.count).to be 3

    log.delete_before( Time.at(4*100-1) )
    expect(log.count).to be 2

    log.delete_before( Time.at(9*100) )
    expect(log.count).to be 0
  end

  it '別のLogが管理するデータとは影響し合わない' do
    time_source.set(Time.at(100))

    logger.warn("test")
    logger.error(StandardError.new("test"))
    logger.close

    backtest_logger.warn("test")
    backtest_logger.error(StandardError.new("test"))
    backtest_logger.close

    expect(log.count).to be 1
    log_data = log.get(0)
    expect(log_data.size).to be > 0

    expect(backtest_log.count).to be 1
    log_data = backtest_log.get(0)
    expect(log_data.size).to be > 0

    log.delete_before( Time.at(200) )
    expect(log.count).to be 0
    expect(backtest_log.count).to be 1

    backtest_log.delete_before( Time.at(200) )
    expect(backtest_log.count).to be 0
  end

end
