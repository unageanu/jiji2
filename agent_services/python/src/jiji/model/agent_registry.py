import importlib
import inspect

from jiji.model.agent import Agent
from jiji.model.exceptions import illigal_argument

class AgentRegistry():

    def __init__(self):
        self.contexts = dict()
        self.codes = dict()

    def register_source(self, name, body):
        context = dict()
        code = compile(body, name, 'exec')
        exec(code, context) # pylint: disable=exec-used
        self.contexts[name] = context
        self.codes[name] = body
        self._invalidate_cache(name)

    def unregister_source(self, name):
        del self.contexts[name]
        del self.codes[name]

    def is_source_registered(self, name):
        return name in self.contexts

    def get_agent_source(self, name):
        return self.codes[name]

    def get_agent_class_names(self):
        classes = []
        for item in self.contexts.items():
            classes.extend(self.__extract_class_names(item))
        return classes

    def get_agent_class(self, name):
        steps = name.split("@")
        if len(steps) < 2:
            return illigal_argument('illegal name. name={0}'.format(name))
        return self.contexts[steps[1]][steps[0]]

    def __extract_class_names(self, item):
        name = item[0]
        dic = item[1]
        names = []
        for item in dic.items():
            if self._is_agent_class(item[1]):
                names.append('{0}@{1}'.format(item[0], name))
        return names

    @staticmethod
    def _is_agent_class(candidate):
        return inspect.isclass(candidate) \
           and issubclass(candidate, Agent) \
           and candidate != Agent

    @staticmethod
    def _invalidate_cache(name):
        try:
            module = importlib.import_module(name)
            importlib.reload(module)
        except Exception: # pylint: disable=broad-except
            pass # ignore
