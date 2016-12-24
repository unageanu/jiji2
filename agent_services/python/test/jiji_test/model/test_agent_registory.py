import unittest

from jiji.model.agent_registry import AgentRegistry
from jiji.model.exceptions import IllegalArgumentError

class AgentRegistoryTest(unittest.TestCase):

    SOURCE_01 = """
from jiji.model.agent import Agent

class TestAgent(Agent):
    pass

class TestAgent2(Agent):
    pass

class OtherClass():
    pass

CONST = 100
    """

    SOURCE_02 = """
from jiji.model.agent import Agent

class TestAgent(Agent):
    pass
    """

    def setUp(self):
        self.instance = AgentRegistry()

    def test_register_source(self):
        self.assertEqual(self.instance.is_source_registered("test"), False)
        with self.assertRaises(KeyError):
            self.instance.get_agent_source("test")

        self.instance.register_source("test", self.SOURCE_01)

        self.assertEqual(self.instance.is_source_registered("test"), True)
        self.assertEqual(
            self.instance.get_agent_source("test"), self.SOURCE_01)
        classes = self.instance.get_agent_class_names()
        classes.sort()
        self.assertEqual(classes, ["TestAgent2@test", "TestAgent@test"])


        self.instance.register_source("test2", self.SOURCE_02)

        self.assertEqual(self.instance.is_source_registered("test2"), True)
        self.assertEqual(
            self.instance.get_agent_source("test2"), self.SOURCE_02)
        classes = self.instance.get_agent_class_names()
        classes.sort()
        self.assertEqual(classes,
            ["TestAgent2@test", "TestAgent@test", "TestAgent@test2"])


        self.instance.unregister_source("test");

        self.assertEqual(self.instance.is_source_registered("test"), False)
        with self.assertRaises(KeyError):
            self.instance.get_agent_source("test")
        self.assertEqual(self.instance.get_agent_class_names(),
            ["TestAgent@test2"])
        self.instance.unregister_source("test2");
        self.assertEqual(self.instance.is_source_registered("test2"), False)
        with self.assertRaises(KeyError):
            self.instance.get_agent_source("test2")
        self.assertEqual(self.instance.get_agent_class_names(), [])

        with self.assertRaises(NameError):
            self.instance.register_source("test2", "xx")


    def test_get_agent_class(self):
        self.instance.register_source("test", self.SOURCE_02)
        agentClass = self.instance.get_agent_class("TestAgent@test")
        self.assertIsNotNone(agentClass())

        with self.assertRaises(KeyError):
            self.instance.get_agent_class("NotFound@test")
        with self.assertRaises(KeyError):
            self.instance.get_agent_class("NotFound@not_found")
        with self.assertRaises(IllegalArgumentError):
            self.instance.get_agent_class("not_found")
