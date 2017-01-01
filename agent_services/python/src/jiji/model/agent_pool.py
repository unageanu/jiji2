import importlib
import inspect
import inject

from jiji.model.exceptions import not_found
from jiji.model.agent_builder import AgentBuilder

class AgentPool():

    def __init__(self):
        self.pool = dict()
        self.serial = 0

    def new_id(self):
        self.serial += 1
        return str(self.serial)

    def register_instance(self, id, agent_instance):
        self.pool[id] = agent_instance
        return id

    def get_instance(self, id):
        try:
            return self.pool[id]
        except KeyError:
            not_found("agent not found. id=" + id)
