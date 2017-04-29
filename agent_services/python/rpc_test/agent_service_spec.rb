# coding: utf-8

require 'rpc_client'

describe 'AgentService' do
  SOURCE_01 = <<SOURCE.freeze
import datetime
from jiji.model.agent import Agent, Property

class TestAgent(Agent):

    @staticmethod
    def get_description():
        return "description"

    @staticmethod
    def get_property_infos():
        return [
            Property("a", "プロパティ1", "aa"),
            Property("b", "プロパティ2")
        ]

    def set_properties(self, properties):
        self.properties = properties

    def post_create(self):
        self.x = 0
        print(self.properties)

    def next_tick(self, tick):
        print(tick)
        self.last_tick = tick

    def save_state(self):
        state = self.properties.copy()
        state["x"] = self.x + 1
        return state

    def restore_state(self, state):
        print(state)
        self.x = state["x"]

    def execute_action(self, action):
        if action == "get_properties":
          return self.properties["a"] + "_" + self.properties["b"]
        elif action == "get_last_tick":
          timezone = datetime.timezone(datetime.timedelta(0))
          time = self.last_tick.timestamp.replace(tzinfo=timezone)
          return str(self.last_tick['USDJPY'].bid) \
            + "_" + str(self.last_tick['USDJPY'].ask) \
            + "_" + str(time)
        elif action == "error":
          raise Exception("error")

SOURCE

  SOURCE_02 = <<SOURCE.freeze
from jiji.model.agent import Agent, Property

class TestAgent(Agent):
    pass

SOURCE

  SOURCE_03 = <<SOURCE.freeze
from jiji.model.agent import Agent, Property

class TestAgent2(Agent):

    @staticmethod
    def get_description():
        return "description2"

SOURCE

  ERROR_01 = <<SOURCE.freeze
raise Exception("error")
SOURCE

  before(:example) do
    @stub = Jiji::RpcClient.instance.agent_service
  end

  after(:example) do
    %w(test test2).each do |n|
      begin
        @stub.unregister(Jiji::Rpc::AgentSourceName.new(name: n))
      rescue StandardError # rubocop:disable Lint/HandleExceptions
        # ignore
      end
    end
  end

  describe '#register' do
    it "can register an agent's source file" do
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.to_a).to eq([])

      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(1)

      agent_class = agent_classes.classes[0]
      expect(agent_class.name).to eq('TestAgent@test')
      expect(agent_class.description).to eq('description')
      expect(agent_class.properties.length).to eq(2)
      expect(agent_class.properties[0].id).to eq('a')
      expect(agent_class.properties[0].name).to eq('プロパティ1')
      expect(agent_class.properties[0].default).to eq('aa')
      expect(agent_class.properties[1].id).to eq('b')
      expect(agent_class.properties[1].name).to eq('プロパティ2')
      expect(agent_class.properties[1].default).to eq('')

      source = Jiji::Rpc::AgentSource.new(name: 'test2', body: SOURCE_02)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by { |item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq('TestAgent@test')
      expect(agent_class.description).to eq('description')
      expect(agent_class.properties.length).to eq(2)
      expect(agent_class.properties[0].id).to eq('a')
      expect(agent_class.properties[0].name).to eq('プロパティ1')
      expect(agent_class.properties[0].default).to eq('aa')
      expect(agent_class.properties[1].id).to eq('b')
      expect(agent_class.properties[1].name).to eq('プロパティ2')
      expect(agent_class.properties[1].default).to eq('')
      agent_class = classes[1]
      expect(agent_class.name).to eq('TestAgent@test2')
      expect(agent_class.description).to eq('')
      expect(agent_class.properties.length).to eq(0)
    end

    it "can update the agent's source file" do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)
      source = Jiji::Rpc::AgentSource.new(name: 'test2', body: SOURCE_02)
      @stub.register(source)

      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_03)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by { |item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq('TestAgent2@test')
      expect(agent_class.description).to eq('description2')
      expect(agent_class.properties.length).to eq(0)
      agent_class = classes[1]
      expect(agent_class.name).to eq('TestAgent@test2')
      expect(agent_class.description).to eq('')
      expect(agent_class.properties.length).to eq(0)
    end

    it "can not update the agent's source file " \
       'when file contains syntax error' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_03)
      @stub.register(source)
      source = Jiji::Rpc::AgentSource.new(name: 'test2', body: SOURCE_02)
      @stub.register(source)

      source = Jiji::Rpc::AgentSource.new(name: 'test', body: ERROR_01)
      expect do
        @stub.register(source)
      end.to raise_exception(GRPC::BadStatus)

      source = Jiji::Rpc::AgentSource.new(name: 'test3', body: ERROR_01)
      expect do
        @stub.register(source)
      end.to raise_exception(GRPC::BadStatus)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by { |item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq('TestAgent2@test')
      expect(agent_class.description).to eq('description2')
      expect(agent_class.properties.length).to eq(0)
      agent_class = classes[1]
      expect(agent_class.name).to eq('TestAgent@test2')
      expect(agent_class.description).to eq('')
      expect(agent_class.properties.length).to eq(0)
    end
  end

  describe '#unregister' do
    it "can unregister the agent's source file" do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_03)
      @stub.register(source)
      source = Jiji::Rpc::AgentSource.new(name: 'test2', body: SOURCE_02)
      @stub.register(source)

      @stub.unregister(Jiji::Rpc::AgentSourceName.new(name: 'test'))
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(1)
      classes = agent_classes.classes.sort_by { |item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq('TestAgent@test2')
      expect(agent_class.description).to eq('')
      expect(agent_class.properties.length).to eq(0)

      @stub.unregister(Jiji::Rpc::AgentSourceName.new(name: 'test2'))
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(0)
    end
  end

  describe '#create_agent_instance' do
    it 'can create an instance of the agent' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        agent_name:        'テスト',
        property_settings: [
          Jiji::Rpc::PropertySetting.new({
            id: 'a', value: 'aaaa'
          }),
          Jiji::Rpc::PropertySetting.new({
            id: 'b', value: ''
          })
        ]
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      message = @stub.send_action(Jiji::Rpc::SendActionRequest.new(
                                    instance_id: result.instance_id,
                                    action_id:   'get_properties'
      )).message

      expect(message).to eq 'aaaa_'
    end

    it 'raises an error if an unknown agent class is specified' do
      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@unknown',
        property_settings: []
      })
      expect do
        @stub.create_agent_instance(request)
      end.to raise_exception(GRPC::BadStatus)
    end
  end

  describe '#delete_agent_instance' do
    it 'can delete an instance of the agent' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      request = Jiji::Rpc::AgentDeletionRequest.new(
        instance_id: result.instance_id)
      @stub.delete_agent_instance(request)
    end

    it 'raises an error if an instance is not found.' do
      expect do
        request = Jiji::Rpc::AgentDeletionRequest.new(instance_id: 'not_found')
        @stub.delete_agent_instance(request)
      end.to raise_exception(GRPC::BadStatus)
    end
  end

  describe '#get_agent_state' do
    it 'can retrieve a state of the agent' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty
      instance_id = result.instance_id

      request = Jiji::Rpc::ExecPostCreateRequest.new(
        instance_id: instance_id)
      @stub.exec_post_create(request)

      request = Jiji::Rpc::GetAgentStateRequest.new(
        instance_id: instance_id)
      result = @stub.get_agent_state(request)
      expect(result.state).not_to be_empty
      state = result.state

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty
      instance_id = result.instance_id

      request = Jiji::Rpc::RestoreAgentStateRequest.new(
        instance_id: instance_id, state: state)
      @stub.restore_agent_state(request)
    end

    it 'raises an error if an instance is not found.' do
      expect do
        request = Jiji::Rpc::GetAgentStateRequest.new(instance_id: 'not_found')
        @stub.get_agent_state(request)
      end.to raise_exception(GRPC::BadStatus)
    end
  end

  describe '#next_tick' do
    it 'can send a tick data to the agent' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      date = DateTime.new(2017, 1, 1, 19, 2, 34, 0)
      request = Jiji::Rpc::NextTickRequest.new(
        instance_id: result.instance_id,
        tick:        Jiji::Rpc::Tick.new(
          timestamp: Google::Protobuf::Timestamp.new(
            seconds: date.to_i, nanos: 0),
          values:    [
            Jiji::Rpc::Tick::Value.new(ask: 112.3, bid: 112, pair: 'USDJPY'),
            Jiji::Rpc::Tick::Value.new(ask: 122.3, bid: 122, pair: 'EURJPY')
          ]
        )
      )
      @stub.next_tick(request)

      message = @stub.send_action(Jiji::Rpc::SendActionRequest.new(
                                    instance_id: result.instance_id,
                                    action_id:   'get_last_tick'
      )).message

      expect(message).to eq'112.0_112.3_2017-01-02 04:02:34+00:00'

      date = DateTime.new(2017, 1, 1, 19, 2, 49, 0)
      request = Jiji::Rpc::NextTickRequest.new(
        instance_id: result.instance_id,
        tick:        Jiji::Rpc::Tick.new(
          timestamp: Google::Protobuf::Timestamp.new(
            seconds: date.to_i, nanos: 0),
          values:    [
            Jiji::Rpc::Tick::Value.new(ask: 113.3, bid: 113, pair: 'USDJPY'),
            Jiji::Rpc::Tick::Value.new(ask: 123.3, bid: 123, pair: 'EURJPY')
          ]
        )
      )
      @stub.next_tick(request)

      message = @stub.send_action(Jiji::Rpc::SendActionRequest.new(
                                    instance_id: result.instance_id,
                                    action_id:   'get_last_tick'
      )).message

      expect(message).to eq'113.0_113.3_2017-01-02 04:02:49+00:00'
    end

    it 'raises an error if an instance is not found.' do
      expect do
        date = DateTime.new(2017, 1, 1, 19, 2, 34)
        request = Jiji::Rpc::NextTickRequest.new(
          instance_id: 'not_found',
          tick:        Jiji::Rpc::Tick.new(
            timestamp: Google::Protobuf::Timestamp.new(
              seconds: date.to_i, nanos: 0),
            values:    [
              Jiji::Rpc::Tick::Value.new(ask: 112.3, bid: 112, pair: 'USDJPY'),
              Jiji::Rpc::Tick::Value.new(ask: 122.3, bid: 122, pair: 'EURJPY')
            ]
          )
        )
        @stub.next_tick(request)
      end.to raise_exception(GRPC::BadStatus)
    end
  end

  describe '#set_agent_Properties' do
    it 'can update the agent properties' do
      source = Jiji::Rpc::AgentSource.new(name: 'test', body: SOURCE_01)
      @stub.register(source)

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        property_settings: [
          Jiji::Rpc::PropertySetting.new({
            id: 'a', value: 'aaaa'
          }),
          Jiji::Rpc::PropertySetting.new({
            id: 'b', value: 'bb'
          })
        ]
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      request = Jiji::Rpc::SetAgentPropertiesRequest.new({
        instance_id:       result.instance_id,
        property_settings: [
          Jiji::Rpc::PropertySetting.new({
            id: 'a', value: 'a2'
          }),
          Jiji::Rpc::PropertySetting.new({
            id: 'b', value: 'b2'
          })
        ]
      })
      @stub.set_agent_properties(request)

      message = @stub.send_action(Jiji::Rpc::SendActionRequest.new(
                                    instance_id: result.instance_id,
                                    action_id:   'get_properties'
      )).message

      expect(message).to eq 'a2_b2'
    end

    it 'raises an error if an instance is not found.' do
      expect do
        request = Jiji::Rpc::SetAgentPropertiesRequest.new({
          instance_id:       'not_found',
          property_settings: [
            Jiji::Rpc::PropertySetting.new({
              id: 'a', value: 'a2'
            })
          ]
        })
        @stub.set_agent_properties(request)
      end.to raise_exception(GRPC::BadStatus)
    end
  end
end
