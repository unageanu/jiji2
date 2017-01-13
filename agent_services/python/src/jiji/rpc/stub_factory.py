import grpc
import logging_pb2

class StubFactory():

    def create_logger_stub(self):
        return logging_pb2.LoggerServiceStub(self.__channel())

    def __channel(self):
        return grpc.insecure_channel('localhost:{0}'.format('50052'))
