import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import agent_pb2 as agent__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2


class BrokerServiceStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.GetPairs = channel.unary_unary(
        '/jiji.rpc.BrokerService/GetPairs',
        request_serializer=broker__pb2.GetPairsRequest.SerializeToString,
        response_deserializer=broker__pb2.GetPairsResponse.FromString,
        )
    self.GetTick = channel.unary_unary(
        '/jiji.rpc.BrokerService/GetTick',
        request_serializer=broker__pb2.GetTickRequest.SerializeToString,
        response_deserializer=agent__pb2.Tick.FromString,
        )
    self.RetrieveRates = channel.unary_unary(
        '/jiji.rpc.BrokerService/RetrieveRates',
        request_serializer=broker__pb2.RetrieveRatesRequest.SerializeToString,
        response_deserializer=broker__pb2.Rates.FromString,
        )


class BrokerServiceServicer(object):

  def GetPairs(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetTick(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def RetrieveRates(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_BrokerServiceServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'GetPairs': grpc.unary_unary_rpc_method_handler(
          servicer.GetPairs,
          request_deserializer=broker__pb2.GetPairsRequest.FromString,
          response_serializer=broker__pb2.GetPairsResponse.SerializeToString,
      ),
      'GetTick': grpc.unary_unary_rpc_method_handler(
          servicer.GetTick,
          request_deserializer=broker__pb2.GetTickRequest.FromString,
          response_serializer=agent__pb2.Tick.SerializeToString,
      ),
      'RetrieveRates': grpc.unary_unary_rpc_method_handler(
          servicer.RetrieveRates,
          request_deserializer=broker__pb2.RetrieveRatesRequest.FromString,
          response_serializer=broker__pb2.Rates.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'jiji.rpc.BrokerService', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
