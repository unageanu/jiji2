import sys
import inject
import itertools
from importlib.abc import MetaPathFinder, ResourceLoader
from importlib.machinery import ModuleSpec
from jiji.model.agent_registry import AgentRegistry

class AgentSourcePathEntryFinder(MetaPathFinder):
    def __init__(self, registry):
        self.registry = registry

    def find_spec(self, fullname, path, target):
        if not self.registry.is_source_registered(fullname):
            return None
        else:
            return ModuleSpec(
                name=fullname,
                loader=AgentSourceLoader(fullname, self.registry),
                origin=None
            )

class AgentSourceLoader(ResourceLoader):
    def __init__(self, name, registry):
        self.name = name
        self.registry = registry

    def exec_module(self, module):
        body = self.registry.get_agent_source(self.name)
        code = compile(self.get_data(self.name), self.name, 'exec')
        exec(code, module.__dict__)
        return module

    def get_data(self, path):
        return self.registry.get_agent_source(self.name)

@inject.params(agent_registry=AgentRegistry)
def register_hook(agent_registry):
    sys.meta_path.append(AgentSourcePathEntryFinder(agent_registry))

def unregister_hook():
    for i in sys.meta_path:
        if isinstance(i, AgentSourcePathEntryFinder):
            sys.meta_path.remove(i)
