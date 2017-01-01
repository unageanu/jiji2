from concurrent import futures
import time
import inject
import grpc

import agent_pb2_grpc
from jiji.model.agent_source_loader import register_hook, unregister_hook
from jiji.composing.injector import initialize
from jiji.services.agent_service import AgentService

_ONE_DAY_IN_SECONDS = 60 * 60 * 24

def serve():
    initialize()
    register_hook()

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
        AgentService(), server)

if __name__ == '__main__':
    serve()
