import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import health_check_pb2 as health__check__pb2


class HealthCheckServiceStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.Status = channel.unary_unary(
        '/jiji.rpc.HealthCheckService/Status',
        request_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
        response_deserializer=health__check__pb2.GetStatusResponse.FromString,
        )


class HealthCheckServiceServicer(object):

  def Status(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_HealthCheckServiceServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'Status': grpc.unary_unary_rpc_method_handler(
          servicer.Status,
          request_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
          response_serializer=health__check__pb2.GetStatusResponse.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'jiji.rpc.HealthCheckService', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
