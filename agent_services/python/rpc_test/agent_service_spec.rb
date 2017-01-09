# coding: utf-8

require 'rpc_client'

describe 'AgentService' do
  SOURCE_01 = <<SOURCE.freeze
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
        print(self.agent_name)
        print(self.properties)

    def next_tick(self, tick):
        print(tick)

    def save_state(self):
        state = self.properties.copy()
        state["x"] = self.x + 1
        return state

    def restore_state(self, state):
        print(state)
        self.x = state["x"]

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
        agent_name:        'エージェント1',
        state:             '',
        property_settings: [
          Jiji::Rpc::AgentCreationRequest::PropertySetting.new({
            id: 'a', value: 'aaaa'
          }),
          Jiji::Rpc::AgentCreationRequest::PropertySetting.new({
            id: 'b', value: ''
          })
        ]
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty
    end

    it 'raises an error if an unknown agent class is specified' do
      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@unknown',
        agent_name:        'エージェント1',
        state:             '',
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
        agent_name:        'エージェント1',
        state:             '',
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
        agent_name:        'エージェント1',
        state:             '',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      request = Jiji::Rpc::GetAgentStateRequest.new(
        instance_id: result.instance_id)
      result = @stub.get_agent_state(request)
      expect(result.state).not_to be_empty

      request = Jiji::Rpc::AgentCreationRequest.new({
        class_name:        'TestAgent@test',
        agent_name:        'エージェント2',
        state:             result.state,
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty
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
        agent_name:        'エージェント1',
        state:             '',
        property_settings: []
      })
      result = @stub.create_agent_instance(request)
      expect(result.instance_id).not_to be_empty

      date = DateTime.new(2017, 1, 1, 19, 2, 34)
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
end
