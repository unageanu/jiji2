# coding: utf-8

require 'client'

describe 'ログ取得' do
  before(:context) do
    register_logs
  end

  after(:context) do
    @agent_registry.remove_source('aaa')
    Jiji::Model::Logging::LogData.drop
  end

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /logs/rmt でリアルトレードのログを取得できる' do
    r = @client.get('logs/rmt', {
      'index' => 0
    })
    expect(r.status).to eq 200
    expect(r.body['size']).to be > 0
    expect(r.body['body'].length).to be > 0
  end

  it 'GET /logs/:backtest_id でバックテストのログを取得できる' do
    r = @client.get("logs/#{@test._id}",  {
      'index' => 0
    })
    expect(r.status).to eq 200
    expect(r.body['size']).to be > 0
    expect(r.body['body'].length).to be > 0
  end

  it 'GET /logs/rmt/count でリアルトレードのログ数を取得できる' do
    r = @client.get('logs/rmt/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
  end

  it 'GET /logs/:backtest_id/count でバックテストのログ数を取得できる' do
    r = @client.get("logs/#{@test._id}/count")
    expect(r.status).to eq 200
    expect(r.body['count']).to be 1
  end

  def register_logs
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    register_log
    register_log(@test._id)
  end

  def register_log(backtest_id = nil)
    time_source = Jiji::Utils::TimeSource.new
    log = Jiji::Model::Logging::Log.new(time_source, backtest_id)

    log.write('test')
    log.close
  end
end
