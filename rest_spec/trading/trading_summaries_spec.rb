# coding: utf-8

require 'client'

describe '取引サマリ取得' do
  before(:context) do
    register_positions
  end

  after(:context) do
    @agent_registry.remove_source('aaa')
    Jiji::Model::Trading::Position.delete_all
  end

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /trading-summaries/rmt でリアルトレードのサマリを取得できる' do
    r = @client.get('trading-summaries/rmt',  {
      'start' => Time.new(2015, 5, 1).iso8601,
      'end'   => Time.new(2015, 5, 9).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 2

    r = @client.get('trading-summaries/rmt',  {
      'start' => Time.new(2015, 5, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 1

    r = @client.get('trading-summaries/rmt')
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 2
  end

  it 'GET /trading-summaries/:backtest_id でバックテストのサマリを取得できる' do
    r = @client.get("trading-summaries/#{@test._id}",  {
      'start' => Time.new(2015, 5, 1).iso8601,
      'end'   => Time.new(2015, 5, 9).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 2

    r = @client.get("trading-summaries/#{@test._id}",  {
      'start' => Time.new(2015, 5, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 1

    r = @client.get("trading-summaries/#{@test._id}")
    expect(r.status).to eq 200
    expect(r.body['states']['count']).to be 2
  end

  def register_positions
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry      = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    register_position(data_builder)
    register_position(data_builder, @test._id)
  end

  def register_position(data_builder, backtest_id = nil)
    position1 = data_builder.new_position(1,
      backtest_id, :EURJPY, Time.new(2015, 5, 2))
    position1.update_state_to_closed
    position1.save

    position1 = data_builder.new_position(1,
      backtest_id, :USDJPY, Time.new(2015, 5, 3))
    position1.save
  end
end
