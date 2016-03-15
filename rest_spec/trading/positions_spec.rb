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

  it 'GET /positions?backtest_id=rmt でリアルトレードの建玉を取得できる' do
    r = @client.get('positions', {
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

    r = @client.get('positions', {
      'backtest_id' => nil,
      'start'       => Time.new(2015, 4, 1).iso8601,
      'end'         => Time.new(2015, 4, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 0
  end

  it 'GET /positions/rmt で取得数を指定してリアルトレードの建玉を取得できる' do
    r = @client.get('positions', {
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

    r = @client.get('positions', {
      'backtest_id' => nil,
      'order'       => 'entered_at',
      'direction'   => 'asc',
      'offset'      => 1,
      'limit'       => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i

    r = @client.get('positions', {
      'backtest_id' => nil,
      'order'       => 'entered_at',
      'direction'   => 'desc',
      'offset'      => 0,
      'limit'       => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i

    r = @client.get('positions', {
      'order'     => 'entered_at',
      'direction' => 'desc',
      'status'    => 'live',
      'offset'    => 0,
      'limit'     => 2
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
    r = @client.get('positions/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
    expect(r.body['not_exited']).to be 1

    r = @client.get('positions/count', {
      'status'      => 'live',
      'backtest_id' => nil
    })
    expect(r.status).to eq 200
    expect(r.body['count']).to be 1
    expect(r.body['not_exited']).to be 1
  end

  it 'GET /positions?backtest_id=:backtest_id でバックテストの建玉を取得できる' do
    r = @client.get('positions', {
      'backtest_id' => @test.id,
      'start'       => Time.new(2015, 5, 1).iso8601,
      'end'         => Time.new(2015, 5, 9).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    r.body.each do |position|
      expect(position['pair_name']).not_to be nil
      expect(position['profit_or_loss']).not_to be nil
      expect(position['entered_at']).not_to be nil
    end

    r = @client.get('positions', {
      'backtest_id' => @test.id,
      'start'       => Time.new(2015, 4, 1).iso8601,
      'end'         => Time.new(2015, 4, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 0
  end

  it 'GET /positions/?backtest_id=:backtest_id で取得数を指定してバックテストの建玉を取得できる' do
    r = @client.get('positions', {
      'backtest_id' => @test.id,
      'order'       => 'entered_at',
      'direction'   => 'desc',
      'offset'      => 1,
      'limit'       => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 2).to_i

    r = @client.get('positions', {
      'backtest_id' => @test.id,
      'order'       => 'entered_at',
      'direction'   => 'asc',
      'offset'      => 1,
      'limit'       => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i

    r = @client.get('positions', {
      'backtest_id' => @test.id,
      'order'       => 'entered_at',
      'direction'   => 'desc',
      'offset'      => 0,
      'limit'       => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    position = r.body[0]
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
    entered_at = Time.iso8601(position['entered_at']).to_i
    expect(entered_at).to eq Time.new(2015, 5, 3).to_i
  end

  it 'GET /positions/count?backtest_id=:backtest_id でバックテストの建玉数を取得できる' do
    r = @client.get('positions/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
    expect(r.body['not_exited']).to be 1
  end

  it 'GET /positions/:position_id で建玉を取得できる' do
    r = @client.get('positions')
    expect(r.status).to eq 200

    id = r.body[0]['id']

    r = @client.get("positions/#{id}")
    expect(r.status).to eq 200
    position = r.body
    expect(position['id']).to eq id
    expect(position['pair_name']).not_to be nil
    expect(position['profit_or_loss']).not_to be nil
  end

  it 'GET /positions/download でCSVデータをダウンロードできる' do
    r = @client.download_csv('positions/download')
    expect(r.status).to eq 200
    expect(r.body.lines.size).to eq 3

    r = @client.download_csv('positions/download', {
      'backtest_id' => @test.id,
      'order'       => 'entered_at',
      'direction'   => 'asc',
      'start'       => Time.new(2015, 4, 1).iso8601,
      'end'         => Time.new(2015, 5, 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.lines.size).to eq 2
  end

  def register_positions
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    setting = data_builder.register_agent_setting
    setting.backtest = @test
    setting.save
    rmt_setting = data_builder.register_agent_setting

    register_position(data_builder, rmt_setting)
    register_position(data_builder, setting, @test)
  end

  def register_position(data_builder, agent_setting, backtest = nil)
    position1 = data_builder.new_position(1,
      backtest, agent_setting, :EURJPY, Time.new(2015, 5, 2))
    position1.update_state_to_closed
    position1.save

    position1 = data_builder.new_position(1,
      backtest, agent_setting, :USDJPY, Time.new(2015, 5, 3))
    position1.save
  end
end
