import unittest

from jiji.model.agent_registry import AgentRegistry
from jiji.model.agent_source_loader import register_hook, unregister_hook
import jiji.model.exceptions
import importlib

class AgentSourceLoaderTest(unittest.TestCase):

    UTILS_01 = """
def test_method():
    return "test"
    """

    UTILS_02 = """
def test_method():
    return "test2"
    """

    UTILS_03 = """
def test_method3():
    return "test3"
    """

    AGENT_01 = """
from jiji.model.agent import Agent
import agent_utils

class TestAgent(Agent):

    def method(self):
        return agent_utils.test_method()
    """

    AGENT_02 = """
from jiji.model.agent import Agent
import agent_utils

class TestAgent(Agent):

    def method(self):
        return agent_utils.test_method() + "x"
    """

    ERROR_01 = """
raise "error"
    """

    def setUp(self):
        self.registry = AgentRegistry()
        register_hook(self.registry)

    def tearDown(self):
        unregister_hook()

    def test_import_utilities(self):
        self.registry.register_source("agent_utils", self.UTILS_01)
        self.registry.register_source("test_agent", self.AGENT_01)
        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance1 = agentClass()
        self.assertEqual(instance1.method(), "test")

        self.registry.register_source("agent_utils", self.UTILS_02)
        self.assertEqual(instance1.method(), "test2")

        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance2 = agentClass()
        self.assertEqual(instance2.method(), "test2")


        self.registry.register_source("test_agent", self.AGENT_02)
        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance3 = agentClass()
        self.assertEqual(instance3.method(), "test2x")
        self.assertEqual(instance2.method(), "test2")
        self.assertEqual(instance1.method(), "test2")


    def test_failed_to_load_utilities(self):
        self.registry.register_source("agent_utils", self.UTILS_01)
        self.registry.register_source("test_agent", self.AGENT_01)
        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance1 = agentClass()
        self.assertEqual(instance1.method(), "test")

        with self.assertRaises(Exception):
            self.registry.register_source("agent_utils", self.ERROR_01)

        self.assertEqual(instance1.method(), "test")

        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance2 = agentClass()
        self.assertEqual(instance2.method(), "test")

        with self.assertRaises(Exception):
            self.registry.register_source("test_agent", ERROR_01)

        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance3 = agentClass()
        self.assertEqual(instance3.method(), "test")
        self.assertEqual(instance2.method(), "test")
        self.assertEqual(instance1.method(), "test")

    def test_unregister_utility_method(self):
        self.registry.register_source("agent_utils", self.UTILS_01)
        self.registry.register_source("test_agent", self.AGENT_01)
        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance1 = agentClass()
        self.assertEqual(instance1.method(), "test")

        self.registry.register_source("agent_utils", self.UTILS_03)
        self.assertEqual(instance1.method(), "test")

        agentClass = self.registry.get_agent_class("TestAgent@test_agent")
        instance2 = agentClass()
        self.assertEqual(instance2.method(), "test")
