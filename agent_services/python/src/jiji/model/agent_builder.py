import inject

from jiji.model.agent_registry import AgentRegistry
from jiji.rpc.stub_factory import StubFactory
from jiji.model.logger import Logger
from jiji.model.broker import Broker

class AgentBuilder():

    @inject.params(agent_registry=AgentRegistry, stub_factory=StubFactory)
    def __init__(self, agent_registry, stub_factory):
        self.agent_registry = agent_registry
        self.stub_factory = stub_factory

    def create_agent(self, instance_id, class_name, agent_name, properties):
        agent_class = self.agent_registry.get_agent_class(class_name)
        instance = agent_class()
        self.__initialize_agent_instance(instance_id,
            instance, agent_name or class_name, properties)
        return instance

    def __initialize_agent_instance(self, \
            instance_id, instance, agent_name, properties):
        instance.set_agent_name(agent_name)
        instance.set_properties(properties)
        self.__inject_components(instance_id, instance)
        return instance

    def __inject_components(self, instance_id, instance):
        instance.broker = self.__create_broker(instance_id)
        instance.logger = self.__create_logger(instance_id)
        instance.graph_factory = self.__create_graph_factory(instance_id)
        instance.notifier = self.__create_notifier(instance_id)

    def __create_broker(self, instance_id):
        return Broker(instance_id, self.stub_factory)

    def __create_logger(self, instance_id):
        return Logger(instance_id, self.stub_factory)

    def __create_graph_factory(self, instance_id):
        pass #TODO

    def __create_notifier(self, instance_id):
        pass #TODO
