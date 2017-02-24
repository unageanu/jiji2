import unittest

from jiji.model.logger import Logger
from jiji.rpc.stub_factory import StubFactory
from utils.agent_register import AgentRegister

class LoggerTest(unittest.TestCase):

    def setUp(self):
        self.stub_factory = StubFactory()
        self.agent_register = AgentRegister()
        self.agent_register.initialize()
        self.agent_register.register_agent()

    def test_logging_error(self):
        logger = Logger("unknown", self.stub_factory)

        with self.assertRaises(Exception):
            logger.info("info")
