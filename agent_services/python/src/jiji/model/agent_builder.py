import importlib
import inspect
import inject

from jiji.model.agent import Agent
from jiji.model.exceptions import not_found
from jiji.model.agent_registry import AgentRegistry

class AgentBuilder():

    @inject.params(agent_registry=AgentRegistry)
    def __init__(self, agent_registry):
        self.agent_registry = agent_registry

    def build_agent(self, id, agent_class_name, agent_name, properties, state=None):
        agent_class = self.agent_registry.get_agent_class(agent_class_name)
        agent_instance = agent_class()
        agent_instance.agent_name = agent_name
        self.__initialize_agent_instance(id, agent_instance, properties, state)
        return agent_instance

    def __initialize_agent_instance(self, id, instance, properties, state):
        instance.set_properties(properties)
        self.__inject_components(id, instance)
        instance.post_create()
        if (state):
            instance.restore_state(state)
        return instance

    def __inject_components(self, id, instance):
        instance.broker = self.__create_broker(id)
        instance.logger = self.__create_logger(id)
        instance.graph_factory = self.__create_graph_factory(id)
        instance.notifier = self.__create_notifier(id)

    def __create_broker(self, id):
        pass #TODO

    def __create_logger(self, id):
        pass #TODO

    def __create_graph_factory(self, id):
        pass #TODO

    def __create_notifier(self, id):
        pass #TODO
