from abc import ABCMeta

class Agent(metaclass=ABCMeta):

    def __init__(self):
        self.properties = {}

    @staticmethod
    def get_description():
        return ""

    @staticmethod
    def get_property_infos():
        return []


    def post_create(self):
        pass

    def set_properties(self, properties):
        self.properties = properties


    def next_tick(self, tick):
        pass


    def save_state(self): # pylint: disable=no-self-use
        return None

    def restore_state(self, state):
        pass


class Property():
    def __init__(self, property_id, name, default=""):
        self.property_id = property_id
        self.name = name
        self.default = default
