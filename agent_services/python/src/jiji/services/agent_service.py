import inject
import agent_pb2
import agent_pb2_grpc
from google.protobuf import empty_pb2 as empty

from jiji.model.agent_registry import AgentRegistry
from jiji.model.agent_pool import AgentPool
from jiji.model.agent_builder import AgentBuilder
from jiji.model.state_serializer import StateSerializer
from jiji.services.abstract_service import AbstractService


print(agent_pb2)

class AgentService(AbstractService, agent_pb2_grpc.AgentServiceServicer):

    @inject.params(agent_pool=AgentPool, agent_registry=AgentRegistry,
        agent_builder=AgentBuilder, state_serializer=StateSerializer)
    def __init__(self, agent_pool, agent_registry, agent_builder, state_serializer):
        self.agent_pool = agent_pool
        self.agent_builder = agent_builder
        self.agent_registry = agent_registry
        self.state_serializer = state_serializer

    def NextTick(self, request, context):
        print(request)
        return empty.Empty()

    def Register(self, request, context):
        try:
            self.agent_registry.register_source(request.name, request.body)
            return empty.Empty()
        except Exception as error:
            self._handle_error(error, context)

    def Unregister(self, request, context):
        print(request)
        try:
            self.agent_registry.unregister_source(request.name, request.body)
            return empty.Empty()
        except Exception as error:
            self._handle_error(error, context)

    def GetAgentClasses(self, request, context):
        print(request)
        try:
            agent_class_names = self.agent_registry.get_agent_class_names()
            classes = map(self.__extract_agent_class, agent_class_names)
            return agent_pb2.AgentClasses(classes=classes)
        except Exception as error:
            self._handle_error(error, context)

    def CreateAgentInstance(self, request, context):
        print(request)
        try:
            properties = self.__extract_properties(request.properties)
            state = self.state_serializer.deserialize(request.state)
            agent_id =  self.agent_pool.new_id()
            agent_instance = self.agent_builder.build_agent(agent_id, \
                agent_class_name, agent_name, properties, state)
            self.agent_pool.register(agent_id, agent_instance)
            return agent_pb2.AgentCreationResult(agent_id)
        except Exception as error:
            self._handle_error(error, context)

    def GetAgentState(self, request, context):
        print(request)
        try:
            instance = self.agent_registry.get_instance(request.instance_id)
            state = self.state_serializer.serialize(instance.save_state())
            return agent_pb2.AgentState(state)
        except Exception as error:
            self._handle_error(error, context)


    def __extract_agent_class(self, name):
        agent_class = self.agent_registry.get_agent_class(name)
        property_infos = map(self.__extract_agent_property_info,
            agent_class.get_property_infos().items())
        return agent_pb2.AgentClasses.AgentClass(name,
            agent_class.get_description(), property_infos)

    def __extract_agent_property_info(self, property_info):
        return agent_pb2.AgentCreationRequest.PropertySetting(
            property_info[0], property_info[1])

    def __extract_properties(self, request):
        properties = dict()
        for p in request.propertySettings:
            properties[p.id] = p.value
        return properties
