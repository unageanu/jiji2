
require 'jiji/test/test_configuration'
require 'jiji/utils/requires'

module Utils
  class AgentRunner

    def initialize
      restart
    end

    def register_agent_file(path, filename = File.basename(path))
      root = Jiji::Utils::Requires.root
      source = @agent_registory.add_source(
        filename, '', :agent, IO.read("#{root}/#{path}"))
      fail source.error unless source.error.nil?
    end

    def start_backtest(agent_setting,
      start_time = Time.new(2015, 12,  8, 0, 0, 0),
      end_time = Time.new(2015, 12,  9, 0, 0, 0))
      @backtest_repository.register({
        'name'          => 'テスト',
        'start_time'    => start_time,
        'end_time'      => end_time,
        'memo'          => 'メモ',
        'pair_names'    => [:USDJPY, :EURUSD],
        'agent_setting' => agent_setting
      })
    end

    def shutdown
      @backtest_repository.stop if @backtest_repository
    end

    def restart
      shutdown

      @container = Jiji::Test::TestContainerFactory.instance.new_container
      @backtest_repository   = @container.lookup(:backtest_repository)
      @action_dispatcher     = @container.lookup(:action_dispatcher)
      @agent_registory       = @container.lookup(:agent_registry)

      activate_demo_securities

      @backtest_repository.load
    end

    def tests
      @backtest_repository.all
    end

    def activate_demo_securities
      factory  = @container.lookup(:securities_factory)
      provider = @container.lookup(:securities_provider)

      provider.set(factory.create(:OANDA_JAPAN_DEMO, {
        access_token: ENV['OANDA_API_ACCESS_TOKEN']
      }))
    end

  end
end
