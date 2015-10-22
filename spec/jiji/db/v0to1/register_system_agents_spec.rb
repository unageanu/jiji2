# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Db::RegisterSystemAgents do
  include_context 'use container'

  let(:script) { container.lookup(:v0to1_register_system_agent) }
  let(:agent_registry) { container.lookup(:agent_registry) }

  it '#id' do
    expect(script.id).to eq 'v0to1/register_system_agents'
  end

  it '#call' do
    expect do
      find_source('moving_average_agent.rb')
    end.to raise_error(Jiji::Errors::NotFoundException)
    expect do
      find_source('cross.rb')
    end.to raise_error(Jiji::Errors::NotFoundException)
    expect do
      find_source('signals.rb')
    end.to raise_error(Jiji::Errors::NotFoundException)

    script.call(nil, nil)
    expect(find_source('moving_average_agent.rb')).not_to be nil
    expect(find_source('cross.rb')).not_to be nil
    expect(find_source('signals.rb')).not_to be nil
  end

  def find_source(name)
    agent_registry.find_agent_source_by_name(name)
  end
end
