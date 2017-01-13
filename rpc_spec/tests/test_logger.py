import unittest

from jiji.model.logger import Logger
from jiji.rpc.stub_factory import StubFactory

class LoggerTest(unittest.TestCase):

    def test_logging(self):
        stub_factory = StubFactory()
        logger = Logger("1", stub_factory)

        logger.info("info")
        logger.debug("debug")
        logger.warn("warn")
        logger.error("error")
