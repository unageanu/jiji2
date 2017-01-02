import pickle

class StateSerializer():

    @staticmethod
    def deserialize(state):
        return pickle.loads(state)

    @staticmethod
    def serialize(state):
        return pickle.dumps(state)
