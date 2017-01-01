import pickle

class StateSerializer():

    def deserialize(self, state):
        return pickle.loads(state)

    def serialize(self, state):
        return pickle.dumps(state)
