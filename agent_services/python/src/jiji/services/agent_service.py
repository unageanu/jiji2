import inject
import agent_pb2
import agent_pb2_grpc
from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module

from jiji.model.agent_registry import AgentRegistry
from jiji.model.agent_pool import AgentPool
from jiji.model.agent_builder import AgentBuilder
from jiji.model.state_serializer import StateSerializer
from jiji.services.abstract_service import AbstractService

class AgentService(AbstractService, agent_pb2_grpc.AgentServiceServicer):

    @inject.params(agent_pool=AgentPool, agent_registry=AgentRegistry, \
        agent_builder=AgentBuilder, state_serializer=StateSerializer)
    def __init__(self, agent_pool, agent_registry, agent_builder, state_serializer):
        self.agent_pool = agent_pool
        self.agent_builder = agent_builder
        self.agent_registry = agent_registry
        self.state_serializer = state_serializer

    def NextTick(self, request, context):
        print(request)
        return empty_pb2.Empty()

    def Register(self, request, context):
        try:
            self.agent_registry.register_source(request.name, request.body)
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()


    def Unregister(self, request, context):
        print(request)
        try:
            self.agent_registry.unregister_source(request.name)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def GetAgentClasses(self, request, context):
        try:
            agent_class_names = self.agent_registry.get_agent_class_names()
            classes = map(self.__extract_agent_class, agent_class_names)
            return agent_pb2.AgentClasses(classes=classes)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.AgentClasses(classes=[])

    def CreateAgentInstance(self, request, context):
        print(request)
        try:
            properties = self._extract_properties(request.properties)
            state = self.state_serializer.deserialize(request.state)
            agent_id = self.agent_pool.new_id()
            agent_instance = self.agent_builder.build_agent(agent_id, \
                request.agent_class_name, request.agent_name, properties, state)
            self.agent_pool.register(agent_id, agent_instance)
            return agent_pb2.AgentCreationResult(agent_id)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.AgentCreationResult("")

    def GetAgentState(self, request, context):
        print(request)
        try:
            instance = self.agent_registry.get_instance(request.instance_id)
            state = self.state_serializer.serialize(instance.save_state())
            return agent_pb2.AgentState(state)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.AgentState(None)

    def __extract_agent_class(self, name):
        agent_class = self.agent_registry.get_agent_class(name)
        property_infos = map(self._extract_agent_property_info, \
            agent_class.get_property_infos())
        return agent_pb2.AgentClasses.AgentClass(name=name, \
            description=agent_class.get_description(), properties=property_infos)

    @staticmethod
    def _extract_agent_property_info(property_info):
        return agent_pb2.AgentClasses.AgentClass.Property(
            id=property_info.property_id, name=property_info.name,
            default=property_info.default)

    @staticmethod
    def _extract_properties(request):
        properties = dict()
        for prop in request.propertySettings:
            properties[prop.id] = prop.value
        return properties
