import inspect

import agent
import exceptions

class AgentRegistry():

    def __init__(self):
        self.contexts = dict()

    def register_source(self, name, body):
        context = dict()
        code = compile(body, name, 'exec')
        exec(code, globals(), context)
        self.contexts[name] = context

    def unregister_source(self, name):
        del self.contexts[name]

    def get_agent_class_names(self):
        classes = []
        for item in self.contexts.items():
            classes.extend(self.__extract_class_names(item))
        return classes

    def get_agent_class(self, name):
        steps = name.split("@")
        if len(steps) < 2 :
            return exceptions.illigal_argument('illegal name name={0}'.format(name))
        return self.contexts[steps[1]][steps[0]]

    def __extract_class_names(self, item):
        name = item[0]
        dic = item[1]
        names = []
        for property in dic.items():
            if self.__is_agent_class(property[1]):
                names.append('{0}@{1}'.format(property[0], name))
        return names

    def __is_agent_class(self, property):
        return inspect.isclass(property) \
           and issubclass(property, agent.Agent)
