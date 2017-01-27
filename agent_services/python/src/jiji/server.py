from concurrent import futures
import time
import grpc

import agent_pb2_grpc
import health_check_pb2_grpc
from jiji.model.agent_source_loader import register_hook
from jiji.composing.injector import initialize
from jiji.services.agent_service import AgentService
from jiji.services.health_check_service import HealthCheckService

_ONE_DAY_IN_SECONDS = 60 * 60 * 24

def serve():
    initialize()
    register_hook() # pylint: disable=no-value-for-parameter

    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    register_services(server)
    server.add_insecure_port('[::]:50051')
    server.start()

    print("start server")
    try:
        while True:
            time.sleep(_ONE_DAY_IN_SECONDS)
    except KeyboardInterrupt:
        server.stop(0)
        print("stop server")

def register_services(server):
    agent_pb2_grpc.add_AgentServiceServicer_to_server(
        AgentService(), server)  # pylint: disable=no-value-for-parameter
    health_check_pb2_grpc.add_HealthCheckServiceServicer_to_server(
        HealthCheckService(), server)  # pylint: disable=no-value-for-parameter

if __name__ == '__main__':
    serve()
