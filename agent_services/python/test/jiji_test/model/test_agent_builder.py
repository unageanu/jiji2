import unittest

from jiji.model.agent_builder import AgentBuilder
from jiji.model.agent_registry import AgentRegistry
import jiji.model.exceptions as exceptions

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
        self.builder = AgentBuilder(self.agent_registry)
        self.agent_registry.register_source("test", self.SOURCE_01)

    def test_build_agent(self):
        agent = self.builder.build_agent("1", "TestAgent@test", "agent1", {
            "a": "aaa",
            "b": "bbb"
        })
        self.assertEqual(agent.agent_name, "agent1")
        self.assertEqual(agent.properties, {
            "a": "aaa",
            "b": "bbb"
        })
        with self.assertRaises(AttributeError):
            agent.state
        self.assertEqual(agent.log, [
            "set_properties",
            "post_create"
        ])

        agent = self.builder.build_agent("2", "TestAgent@test", "agent2", {}, {
            "a": "aaa"
        })
        self.assertEqual(agent.agent_name, "agent2")
        self.assertEqual(agent.properties, {})
        self.assertEqual(agent.state, {
            "a": "aaa"
        })
        self.assertEqual(agent.log, [
            "set_properties",
            "post_create",
            "restore_state"
        ])

        with self.assertRaises(KeyError):
            self.builder.build_agent("3", "NotFound@not_found", "agent3", {})
