import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import logging_pb2 as logging__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2


class LoggerServiceStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.Log = channel.unary_unary(
        '/jiji.rpc.LoggerService/Log',
        request_serializer=logging__pb2.LoggingRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )


class LoggerServiceServicer(object):

  def Log(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_LoggerServiceServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'Log': grpc.unary_unary_rpc_method_handler(
          servicer.Log,
          request_deserializer=logging__pb2.LoggingRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'jiji.rpc.LoggerService', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
