import unittest

from agent_registry import AgentRegistry
import exceptions

class AgentRegistoryTest(unittest.TestCase):

    def setUp(self):
        self.instance = AgentRegistry()

    def test_register_source(self):
        self.instance.register_source("test", """
import agent

class TestAgent(agent.Agent):
    pass

class TestAgent2(agent.Agent):
    pass

class OtherClass():
    pass

CONST = 100
        """)
        classes = self.instance.get_agent_class_names()
        classes.sort()
        self.assertEqual(classes, ["TestAgent2@test", "TestAgent@test"])

        self.instance.register_source("test2", """
import agent

class TestAgent(agent.Agent):
    pass
        """)
        classes = self.instance.get_agent_class_names()
        classes.sort()
        self.assertEqual(classes,
            ["TestAgent2@test", "TestAgent@test", "TestAgent@test2"])

        self.instance.unregister_source("test");
        self.assertEqual(self.instance.get_agent_class_names(),
            ["TestAgent@test2"])
        self.instance.unregister_source("test2");
        self.assertEqual(self.instance.get_agent_class_names(), [])

        with self.assertRaises(NameError):
            self.instance.register_source("test2", "xx")

    def test_get_agent_class(self):
        self.instance.register_source("test", """
import agent

class TestAgent(agent.Agent):
    pass
""")
        agentClass = self.instance.get_agent_class("TestAgent@test")
        self.assertIsNotNone(agentClass())

        with self.assertRaises(KeyError):
            self.instance.get_agent_class("NotFound@test")
        with self.assertRaises(KeyError):
            self.instance.get_agent_class("NotFound@not_found")
        with self.assertRaises(exceptions.IllegalArgumentError):
            self.instance.get_agent_class("not_found")
