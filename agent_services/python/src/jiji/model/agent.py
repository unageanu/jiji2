from abc import ABCMeta

class Agent(metaclass=ABCMeta):

    def __init__(self):
        self.properties = {}

    @classmethod
    def get_description(cls):
        return ""

    @classmethod
    def get_property_infos(cls):
        return {}


    def post_create(self):
        pass

    def set_properties(self, properties):
        self.properties = properties


    def save_state(self): # pylint: disable=no-self-use
        return None

    def restore_state(self, state):
        pass
