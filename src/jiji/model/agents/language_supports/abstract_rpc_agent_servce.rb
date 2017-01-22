# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'forwardable'

module Jiji::Model::Agents::LanguageSupports
  class AbstractRpcAgentService

    include Jiji::Rpc

    def available?
      stub.stub.get_agent_classes(Google::Protobuf::Empty.new)
      true
    rescue Exception # rubocop:disable Lint/RescueException
      false
    end

    def register_source(agent_source)
      source = AgentSource.new({
        name: agent_source.name,
        body: agent_source.body
      })
      stub.register(source)
    rescue Exception => e # rubocop:disable Lint/RescueException
      agent_source.change_state_to_error(e)
    end

    def unregister_source(name)
      stub.unregister(AgentSourceName.new(name: name))
    end

    def retrieve_agent_classes(&block)
      stub.get_agent_classes(Google::Protobuf::Empty.new).classes.each do |cl|
        yield({
          name:        cl.name,
          description: cl.description,
          properties:  cl.properties.map do |p|
            Jiji::Model::Agents::Agent::Property.new(p.id, p.name, p.default)
          end
        })
      end
    end

    def create_agent_instance(config, state = '')
      request = AgentCreationRequest.new({
        class_name:        config.class_name,
        agent_name:        config.agent_name,
        state:             state,
        property_settings: create_property_settings(config.property_settings)
      })
      instance_id = stub.create_agent_instance(request).instance_id
      AgentProxy.new(instance_id, self)
    end

    def delete_agent_instance(instance_id)
      request = AgentDeletionRequest.new(instance_id: instance_id)
      stub.delete_agent_instance(request)
    end

    def retrieve_agent_state(instance_id)
      request = GetAgentStateRequest.new(instance_id: 'not_found')
      stub.get_agent_state(request).state
    end

    def set_properties(instance_id, properties)
      request = SetAgentPropertiesRequest.new({
        instance_id:       instance_id,
        property_settings: create_property_settings(properties)
      })
      stub.set_agent_properties(request)
    end

    def next_tick(instance_id, tick)
      request = NextTickRequest.new(
        instance_id: instance_id,
        tick:        create_tick(tick)
      )
      stub.next_tick(request)
    end

    def execute_action(instance_id, action)
      request = SendActionRequest.new({
        instance_id: instance_id,
        action_id:   action
      })
      stub.send_action(request).message
    end

    private

    def create_property_settings(property_settings)
      property_settings.map do |item|
        PropertySetting.new({
          id: item.id, value: item.value
        })
      end
    end

    def create_tick(tick)
      Tick.new(
        timestamp: Google::Protobuf::Timestamp.new(
          seconds: tick.timestamp.to_i, nanos: 0),
        values:    tick.map do |k, v|
          Tick::Value.new(ask: v.ask, bid: v.bid, pair: k)
        end
      )
    end

  end
end
