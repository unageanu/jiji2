# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'logger'

describe Jiji::Model::Logging::LoggerFactory do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:time_source) { Jiji::Utils::TimeSource.new }

  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
  let(:backtest) do
    agent_registry      = container.lookup(:agent_registry)
    backtest_repository = container.lookup(:backtest_repository)
    agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    data_builder.register_backtest(1, backtest_repository)
  end

  let(:logger_factory) { container.lookup(:logger_factory) }

  after(:example) do
    data_builder.clean
  end

  it '同じバックテストのロガーを取得すると同じインスタンスが返される' do
    rmt_logger = logger_factory.create
    backtest_logger = logger_factory.create(backtest)

    expect(logger_factory.create).to be rmt_logger
    expect(logger_factory.create(backtest)).to be backtest_logger

    rmt_logger.debug('test')
    backtest_logger.warn('test')

    logger_factory.close
  end
end
