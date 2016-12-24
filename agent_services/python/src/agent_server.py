from concurrent import futures
import time

import grpc

import agent_pb2
from google.protobuf import empty_pb2 as empty

_ONE_DAY_IN_SECONDS = 60 * 60 * 24

class AgentService(agent_pb2.AgentServiceServicer):

  def NextTick(self, request, context):
    print request
    return empty.Empty()


def serve():
  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
  agent_pb2.add_AgentServiceServicer_to_server(AgentService(), server)
  server.add_insecure_port('[::]:50051')
  server.start()
  try:
    while True:
      time.sleep(_ONE_DAY_IN_SECONDS)
  except KeyboardInterrupt:
    server.stop(0)

if __name__ == '__main__':
  serve()
