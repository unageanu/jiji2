import inject

from jiji.model.agent_registry import AgentRegistry

class AgentBuilder():

    @inject.params(agent_registry=AgentRegistry)
    def __init__(self, agent_registry):
        self.agent_registry = agent_registry

    def build_agent(self, instance_id, \
            agent_class_name, properties, state=None):
        agent_class = self.agent_registry.get_agent_class(agent_class_name)
        agent_instance = agent_class()
        self.__initialize_agent_instance(instance_id, \
            agent_instance, properties, state)
        return agent_instance

    def __initialize_agent_instance(self, \
            instance_id, instance, properties, state):
        instance.set_properties(properties)
        self.__inject_components(instance_id, instance)
        instance.post_create()
        if state:
            instance.restore_state(state)
        return instance

    def __inject_components(self, instance_id, instance):
        instance.broker = self.__create_broker(instance_id)
        instance.logger = self.__create_logger(instance_id)
        instance.graph_factory = self.__create_graph_factory(instance_id)
        instance.notifier = self.__create_notifier(instance_id)

    def __create_broker(self, instance_id):
        pass #TODO

    def __create_logger(self, instance_id):
        pass #TODO

    def __create_graph_factory(self, instance_id):
        pass #TODO

    def __create_notifier(self, instance_id):
        pass #TODO
