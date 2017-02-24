from jiji.model.exceptions import not_found

class AgentPool():

    def __init__(self):
        self.pool = dict()
        self.serial = 0

    def new_id(self):
        self.serial += 1
        return "python_" + str(self.serial)

    def register_instance(self, instance_id, agent_instance):
        self.pool[instance_id] = agent_instance
        return instance_id

    def unregister_instance(self, instance_id):
        del self.pool[instance_id]

    def get_instance(self, instance_id):
        try:
            return self.pool[instance_id]
        except KeyError:
            not_found("agent not found. instance_id=" + instance_id)
