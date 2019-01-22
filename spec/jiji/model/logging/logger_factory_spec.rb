# frozen_string_literal: true

require 'jiji/test/test_configuration'

require 'logger'

describe Jiji::Model::Logging::LoggerFactory do
  include_context 'use backtests'
  let(:time_source) { Jiji::Utils::TimeSource.new }
  let(:logger_factory) { container.lookup(:logger_factory) }

  it '同じバックテストのロガーを取得すると同じインスタンスが返される' do
    rmt_logger = logger_factory.create
    backtest_logger = logger_factory.create(backtests[0])

    expect(logger_factory.create).to be rmt_logger
    expect(logger_factory.create(backtests[0])).to be backtest_logger

    rmt_logger.debug('test')
    backtest_logger.warn('test')

    logger_factory.close
  end
end
