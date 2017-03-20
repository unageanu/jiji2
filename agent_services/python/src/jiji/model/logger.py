import logging_pb2

class Logger():

    def __init__(self, instance_id, stub_factory):
        self.instance_id = instance_id
        self.stub = stub_factory.create_logger_stub()

    def info(self, message):
        self.stub.Log(self.__create_request("INFO", message))

    def debug(self, message):
        self.stub.Log(self.__create_request("DEBUG", message))

    def warn(self, message):
        self.stub.Log(self.__create_request("WARN", message))

    def error(self, message):
        self.stub.Log(self.__create_request("ERROR", message))

    def fatal(self, message):
        self.stub.Log(self.__create_request("FATAL", message))

    def __create_request(self, log_level, message):
        return logging_pb2.LoggingRequest(instance_id=self.instance_id, \
            log_level=log_level, message=message)
