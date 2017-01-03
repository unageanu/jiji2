import pickle

class StateSerializer():

    @staticmethod
    def deserialize(state):
        if len(state) <= 0:
            return None
        return pickle.loads(state)

    @staticmethod
    def serialize(state):
        return pickle.dumps(state)
