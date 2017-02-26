import unittest

from jiji.model.agent_builder import AgentBuilder
from jiji.model.agent_registry import AgentRegistry
from jiji.rpc.stub_factory import StubFactory

class AgentBuilderTest(unittest.TestCase):

    SOURCE_01 = """
from jiji.model.agent import Agent

class TestAgent(Agent):

    def __init__(self):
        self.log = []

    def post_create(self):
        self.log.append("post_create")

    def set_properties(self, properties):
        self.log.append("set_properties")
        self.properties = properties

    def save_state(self):
        self.log.append("save_state")

    def restore_state(self, state):
        self.log.append("restore_state")
        self.state = state

    """

    def setUp(self):
        self.agent_registry = AgentRegistry()
        self.stub_factory = StubFactory()
        self.builder = AgentBuilder(self.agent_registry, self.stub_factory)
        self.agent_registry.register_source("test", self.SOURCE_01)

    def test_create_and_initialize_agent(self):
        agent = self.builder.create_agent("1", "TestAgent@test", "test", {
            "a": "aaa",
            "b": "bbb"
        })
        self.assertEqual(agent.properties, {
            "a": "aaa",
            "b": "bbb"
        })
        self.assertEqual(agent.agent_name, "test")
        with self.assertRaises(AttributeError):
            agent.state # pylint: disable=pointless-statement
        self.assertEqual(agent.log, [
            "set_properties",
        ])

        agent = self.builder.create_agent("2", "TestAgent@test", "test", {})
        agent.restore_state({
            "a": "aaa"
        })
        self.assertEqual(agent.properties, {})
        self.assertEqual(agent.agent_name, "test")
        self.assertEqual(agent.state, {
            "a": "aaa"
        })
        self.assertEqual(agent.log, [
            "set_properties",
            "restore_state"
        ])

        with self.assertRaises(KeyError):
            self.builder.create_agent("3", "NotFound@not_found", None, {})
