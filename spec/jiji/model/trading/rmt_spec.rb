# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::RMT do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @rmt          = @container.lookup(:rmt)
    @time_source  = @container.lookup(:time_source)
    @settings     = @container.lookup(:setting_repository)
    @registory    = @container.lookup(:agent_registry)

    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
    @registory.add_source('bbb', '', :agent, @data_builder.new_agent_body(2))
  end

  after(:example) do
    @rmt.tear_down
    @data_builder.clean
  end

  it 'エージェントを追加/更新できる' do
    @rmt.setup
    agent_setting = @settings.rmt_setting.agent_setting
    expect(agent_setting.length).to be 0

    @rmt.update_agent_setting([
      { name: 'TestAgent1@aaa', properties: { 'a' => 100, 'b' => 'bb' } },
      { name: 'TestAgent1@aaa', properties: {} },
      { name: 'TestAgent2@bbb' }
    ])
    agent_setting = @settings.rmt_setting.agent_setting
    expect(agent_setting[0]['uuid']).not_to be nil
    expect(agent_setting[0]['name']).to eq 'TestAgent1@aaa'
    expect(agent_setting[0]['properties']).to eq({ 'a' => 100, 'b' => 'bb' })
    expect(@rmt.agents[agent_setting[0][:uuid]]).not_to be nil
    expect(agent_setting[1][:uuid]).not_to be nil
    expect(agent_setting[1][:name]).to eq 'TestAgent1@aaa'
    expect(agent_setting[1][:properties]).to eq({})
    expect(@rmt.agents[agent_setting[1][:uuid]]).not_to be nil
    expect(agent_setting[2][:uuid]).not_to be nil
    expect(agent_setting[2][:name]).to eq 'TestAgent2@bbb'
    expect(agent_setting[2][:properties]).to eq(nil)
    expect(@rmt.agents[agent_setting[2][:uuid]]).not_to be nil

    new_setting = [{
      uuid:       agent_setting[0][:uuid],
      name:       'TestAgent1@aaa',
      properties: { 'a' => 200, 'b' => 'bb' }
    }]
    @rmt.update_agent_setting(new_setting)
    expect(new_setting[0][:uuid]).not_to be nil
    expect(@rmt.agents[new_setting[0][:uuid]]).not_to be nil
    expect(@rmt.agents[agent_setting[1][:uuid]]).to be nil
    expect(@rmt.agents[agent_setting[2][:uuid]]).to be nil

    agent_setting = @settings.rmt_setting.agent_setting
    expect(agent_setting[0]['uuid']).not_to be nil
    expect(agent_setting[0]['name']).to eq 'TestAgent1@aaa'
    expect(agent_setting[0]['properties']).to eq({ 'a' => 200, 'b' => 'bb' })
  end

  it '永続化したデータから状態を復元できる' do
    @rmt.setup
    @rmt.update_agent_setting([
      { name: 'TestAgent1@aaa', properties: { 'a' => 100, 'b' => 'bb' } },
      { name: 'TestAgent1@aaa', properties: {} },
      { name: 'TestAgent2@bbb' }
    ])
    @rmt.tear_down

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @rmt          = @container.lookup(:rmt)
    @settings     = @container.lookup(:setting_repository)
    @rmt.setup

    agent_setting = @settings.rmt_setting.agent_setting
    expect(agent_setting[0]['uuid']).not_to be nil
    expect(agent_setting[0]['name']).to eq 'TestAgent1@aaa'
    expect(agent_setting[0]['properties']).to eq({ 'a' => 100, 'b' => 'bb' })
    expect(@rmt.agents[agent_setting[0]['uuid']]).not_to be nil
    expect(agent_setting[1]['uuid']).not_to be nil
    expect(agent_setting[1][:name]).to eq 'TestAgent1@aaa'
    expect(agent_setting[1][:properties]).to eq({})
    expect(@rmt.agents[agent_setting[1][:uuid]]).not_to be nil
    expect(agent_setting[2][:uuid]).not_to be nil
    expect(agent_setting[2][:name]).to eq 'TestAgent2@bbb'
    expect(agent_setting[2][:properties]).to eq(nil)
    expect(@rmt.agents[agent_setting[2][:uuid]]).not_to be nil
  end
end
