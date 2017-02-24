import atexit
import time
import unittest
import grpc

from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module
from server import Server
from jiji.rpc.stub_factory import StubFactory
from jiji.model.logger import Logger

def suite():
    test_suite = unittest.TestSuite()
    all_test_suite = unittest.defaultTestLoader.discover("rpc_spec/tests", pattern="test_*.py")
    for ts in all_test_suite:
        test_suite.addTest(ts)
    return test_suite

def wait_for_server_startup():
    stub_factory = StubFactory()
    health_check_service = stub_factory.create_health_check_service_stub()
    while True:
        try:
            health_check_service.Status(empty_pb2.Empty())
            return
        except grpc._channel._Rendezvous:
            print("wait for server startup")
            time.sleep(5)


if __name__ == '__main__':

    server = Server()
    server.start()
    atexit.register(lambda : server.stop())

    wait_for_server_startup()

    unittest.TextTestRunner().run(suite())
