import inject

import agent_pb2
import agent_pb2_grpc
from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module

from jiji.model.agent_registry import AgentRegistry
from jiji.model.agent_pool import AgentPool
from jiji.model.agent_builder import AgentBuilder
from jiji.model.state_serializer import StateSerializer
from jiji.services.abstract_service import AbstractService
from jiji.services.converters import convert_tick, convert_properties, convert_agent_property_info

class AgentService(AbstractService, agent_pb2_grpc.AgentServiceServicer):

    @inject.params(agent_pool=AgentPool, agent_registry=AgentRegistry, \
        agent_builder=AgentBuilder, state_serializer=StateSerializer)
    def __init__(self, agent_pool, agent_registry, agent_builder, state_serializer):
        self.agent_pool = agent_pool
        self.agent_builder = agent_builder
        self.agent_registry = agent_registry
        self.state_serializer = state_serializer

    def NextTick(self, request, context):
        try:
            instance = self.agent_pool.get_instance(request.instance_id)
            instance.next_tick(convert_tick(request.tick))
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def Register(self, request, context):
        try:
            self.agent_registry.register_source(request.name, request.body)
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()


    def Unregister(self, request, context):
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
        try:
            properties = convert_properties(request)
            agent_id = self.agent_pool.new_id()
            agent_instance = self.agent_builder.create_agent(
                agent_id, request.class_name, request.agent_name, properties)
            self.agent_pool.register_instance(agent_id, agent_instance)
            return agent_pb2.AgentCreationResult(instance_id=agent_id)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.AgentCreationResult(instance_id="")

    def ExecPostCreate(self, request, context):
        try:
            instance = self.agent_pool.get_instance(request.instance_id)
            instance.post_create()
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def DeleteAgentInstance(self, request, context):
        try:
            self.agent_pool.unregister_instance(request.instance_id)
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def GetAgentState(self, request, context):
        try:
            instance = self.agent_pool.get_instance(request.instance_id)
            state = self.state_serializer.serialize(instance.save_state())
            return agent_pb2.AgentState(state=state)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.AgentState(state=None)

    def RestoreAgentState(self, request, context):
        try:
            state = self.state_serializer.deserialize(request.state)
            instance = self.agent_pool.get_instance(request.instance_id)
            instance.restore_state(state)
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def SetAgentProperties(self, request, context):
        try:
            instance = self.agent_pool.get_instance(request.instance_id)
            properties = convert_properties(request)
            instance.set_properties(properties)
            return empty_pb2.Empty()
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return empty_pb2.Empty()

    def SendAction(self, request, context):
        try:
            instance = self.agent_pool.get_instance(request.instance_id)
            message = instance.execute_action(request.action_id)
            return agent_pb2.SendActionResponse(message=message)
        except Exception as error: # pylint: disable=broad-except
            self._handle_error(error, context)
        return agent_pb2.SendActionResponse(message='ERROR')

    def __extract_agent_class(self, name):
        agent_class = self.agent_registry.get_agent_class(name)
        property_infos = map(convert_agent_property_info, \
            agent_class.get_property_infos())
        return agent_pb2.AgentClasses.AgentClass(name=name, \
            description=agent_class.get_description(), properties=property_infos)
