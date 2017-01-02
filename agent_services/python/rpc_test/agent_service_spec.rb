# coding: utf-8

require 'rpc_client'

describe 'AgentService' do

  SOURCE_01 =<<SOURCE
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

SOURCE

SOURCE_02 =<<SOURCE
from jiji.model.agent import Agent, Property

class TestAgent(Agent):
    pass

SOURCE

SOURCE_03 =<<SOURCE
from jiji.model.agent import Agent, Property

class TestAgent2(Agent):

    @staticmethod
    def get_description():
        return "description2"

SOURCE

ERROR_01 =<<SOURCE
raise Exception("error")
SOURCE


  before(:example) do
    @stub = Jiji::RpcClient.instance.agent_service
  end

  describe '#register' do

    it 'can register agent source file' do
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.to_a).to eq([])

      source = Jiji::Rpc::AgentSource.new(name: "test" , body:SOURCE_01)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(1)

      agent_class = agent_classes.classes[0]
      expect(agent_class.name).to eq("TestAgent@test")
      expect(agent_class.description).to eq("description")
      expect(agent_class.properties.length).to eq(2)
      expect(agent_class.properties[0].id).to eq("a")
      expect(agent_class.properties[0].name).to eq("プロパティ1")
      expect(agent_class.properties[0].default).to eq("aa")
      expect(agent_class.properties[1].id).to eq("b")
      expect(agent_class.properties[1].name).to eq("プロパティ2")
      expect(agent_class.properties[1].default).to eq("")


      source = Jiji::Rpc::AgentSource.new(name: "test2" , body:SOURCE_02)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by {|item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq("TestAgent@test")
      expect(agent_class.description).to eq("description")
      expect(agent_class.properties.length).to eq(2)
      expect(agent_class.properties[0].id).to eq("a")
      expect(agent_class.properties[0].name).to eq("プロパティ1")
      expect(agent_class.properties[0].default).to eq("aa")
      expect(agent_class.properties[1].id).to eq("b")
      expect(agent_class.properties[1].name).to eq("プロパティ2")
      expect(agent_class.properties[1].default).to eq("")
      agent_class = classes[1]
      expect(agent_class.name).to eq("TestAgent@test2")
      expect(agent_class.description).to eq("")
      expect(agent_class.properties.length).to eq(0)


      source = Jiji::Rpc::AgentSource.new(name: "test" , body:SOURCE_03)
      @stub.register(source)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by {|item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq("TestAgent2@test")
      expect(agent_class.description).to eq("description2")
      expect(agent_class.properties.length).to eq(0)
      agent_class = classes[1]
      expect(agent_class.name).to eq("TestAgent@test2")
      expect(agent_class.description).to eq("")
      expect(agent_class.properties.length).to eq(0)


      source = Jiji::Rpc::AgentSource.new(name: "test" , body:ERROR_01)
      expect do
        @stub.register(source)
      end.to raise_exception(GRPC::BadStatus)

      source = Jiji::Rpc::AgentSource.new(name: "test3" , body:ERROR_01)
      expect do
        @stub.register(source)
      end.to raise_exception(GRPC::BadStatus)

      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(2)
      classes = agent_classes.classes.sort_by {|item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq("TestAgent2@test")
      expect(agent_class.description).to eq("description2")
      expect(agent_class.properties.length).to eq(0)
      agent_class = classes[1]
      expect(agent_class.name).to eq("TestAgent@test2")
      expect(agent_class.description).to eq("")
      expect(agent_class.properties.length).to eq(0)


      @stub.unregister(Jiji::Rpc::AgentSourceName.new(name: "test"))
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(1)
      classes = agent_classes.classes.sort_by {|item| item.name }

      agent_class = classes[0]
      expect(agent_class.name).to eq("TestAgent@test2")
      expect(agent_class.description).to eq("")
      expect(agent_class.properties.length).to eq(0)


      @stub.unregister(Jiji::Rpc::AgentSourceName.new(name: "test2"))
      agent_classes = @stub.get_agent_classes(Google::Protobuf::Empty.new)
      expect(agent_classes.classes.length).to eq(0)
    end

  end
end
