import unittest

from jiji.model.agent_pool import AgentPool
import jiji.model.exceptions as exceptions

class AgentPoolTest(unittest.TestCase):

    def setUp(self):
        self.instance = AgentPool()

    def test_new_id(self):
        self.assertEqual(self.instance.new_id(), "1")
        self.assertEqual(self.instance.new_id(), "2")
        self.assertEqual(self.instance.new_id(), "3")
        self.assertEqual(self.instance.new_id(), "4")

    def test_register_instance(self):
        id1 = self.instance.new_id()
        self.instance.register_instance(id1, "aaa")
        id2 = self.instance.new_id()
        self.instance.register_instance(id2, "bbb")

        self.assertEqual(self.instance.get_instance(id1), "aaa")
        self.assertEqual(self.instance.get_instance(id2), "bbb")

        self.instance.unregister_instance(id1)
        with self.assertRaises(exceptions.NotFoundError):
            self.instance.get_instance(id1)
        self.assertEqual(self.instance.get_instance(id2), "bbb")

        with self.assertRaises(exceptions.NotFoundError):
            self.instance.get_instance("not_found")
