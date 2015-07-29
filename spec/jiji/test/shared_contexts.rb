require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

RSpec.shared_context 'use data_builder' do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  after(:example) do
    data_builder.clean
  end
end

RSpec.shared_context 'use container' do
  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
end

RSpec.shared_context 'use backtest' do
  include_context 'use data_builder'
  include_context 'use container'
  let(:agent_registry) { container.lookup(:agent_registry) }
  let(:backtest_repository) { container.lookup(:backtest_repository) }
  let(:backtests) do
    agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    return [
      data_builder.register_backtest(1, backtest_repository),
      data_builder.register_backtest(2, backtest_repository),
      data_builder.register_backtest(3, backtest_repository)
    ]
  end
end
