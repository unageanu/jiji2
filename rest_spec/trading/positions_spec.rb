# coding: utf-8

require 'client'

describe '建玉取得' do
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

  it 'GET /positions/rmt でリアルトレードの建玉を取得できる' do
    r = @client.get('positions/rmt',  {
      'start' => Time.new(2015, 5, 1).iso8601,
      'end'   => Time.new(2015, 5, 9).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    r.body.each do |position|
      expect(position['pair_name']).not_to be nil
      expect(position['profit_or_loss']).not_to be nil
      expect(position['entered_at']).not_to be nil
    end

    r = @client.get('positions/rmt',  {
      'start' => Time.new(2015, 4, 1).iso8601,
      'end'   => Time.new(2015, 4, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 0
  end

  it 'GET /positions/rmt で取得数を指定してリアルトレードの建玉を取得できる' do
    r = @client.get('positions/rmt',  {
      'order'     => 'entered_at',
      'direction' => 'desc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 2).to_i

    r = @client.get('positions/rmt',  {
      'order'     => 'entered_at',
      'direction' => 'asc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i

    r = @client.get('positions/rmt',  {
      'order'     => 'entered_at',
      'direction' => 'desc',
      'offset'    => 0,
      'limit'     => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i
  end

  it 'GET /positions/rmt/count でリアルトレードの建玉数を取得できる' do
    r = @client.get('positions/rmt/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
  end

  it 'GET /positions/:backtest_id でバックテストの建玉を取得できる' do
    r = @client.get("positions/#{@test._id}",  {
      'start' => Time.new(2015, 5, 1).iso8601,
      'end'   => Time.new(2015, 5, 9).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    r.body.each do |position|
      expect(position['pair_name']).not_to be nil
      expect(position['profit_or_loss']).not_to be nil
      expect(position['entered_at']).not_to be nil
    end

    r = @client.get("positions/#{@test._id}",  {
      'start' => Time.new(2015, 4, 1).iso8601,
      'end'   => Time.new(2015, 4, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 0
  end

  it 'GET /positions/:backtest_id で取得数を指定してバックテストの建玉を取得できる' do
    r = @client.get("positions/#{@test._id}",  {
      'order'     => 'entered_at',
      'direction' => 'desc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 2).to_i

    r = @client.get("positions/#{@test._id}",  {
      'order'     => 'entered_at',
      'direction' => 'asc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i

    r = @client.get("positions/#{@test._id}",  {
      'order'     => 'entered_at',
      'direction' => 'desc',
      'offset'    => 0,
      'limit'     => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i
  end

  it 'GET /positions/:backtest_id/count でリアルトレードの建玉数を取得できる' do
    r = @client.get("positions/#{@test._id}/count")
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
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
