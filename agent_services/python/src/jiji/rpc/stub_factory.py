import grpc
import logging_pb2
import health_check_pb2
import broker_pb2

class StubFactory():

    def create_logger_stub(self):
        return logging_pb2.LoggerServiceStub(self.__channel())

    def create_health_check_service_stub(self):
        return health_check_pb2.HealthCheckServiceStub(self.__channel())

    def create_broker_stub(self):
        return broker_pb2.BrokerServiceStub(self.__channel())

    @staticmethod
    def __channel():
        return grpc.insecure_channel('localhost:{0}'.format('50052'))
