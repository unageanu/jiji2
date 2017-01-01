import unittest

from jiji.model.state_serializer import StateSerializer

class StateSerializerTest(unittest.TestCase):

    def setUp(self):
        self.instance = StateSerializer()

    def test_serialize(self):
        self.do_serialize_and_deserialize("aaa")
        self.do_serialize_and_deserialize(2)
        self.do_serialize_and_deserialize(True)
        self.do_serialize_and_deserialize(["a", "b", "c"])
        self.do_serialize_and_deserialize((1, 2))
        self.do_serialize_and_deserialize({
            "string": "aaaa",
            "number": 10,
            "boolean": True,
            "array": [10.2, "aaa", False],
            "dict": {"string": "bbb", "number": -10}
        })
        self.do_serialize_and_deserialize(None)

    def do_serialize_and_deserialize(self, state):
        bytes = self.instance.serialize(state)
        self.assertEqual(self.instance.deserialize(bytes), state)
