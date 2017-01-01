from abc import ABCMeta

class Agent(metaclass=ABCMeta):

    def get_description(self):
        return ""

    def get_property_infos(self):
        return {}


    def post_create(self):
        pass

    def set_properties(self, properties):
        self.properties = properties


    def save_state(self):
        return None

    def restore_state(self, state):
        pass
