import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import agent_pb2 as agent__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2
import broker_pb2 as broker__pb2


class BrokerServiceStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.GetAccount = channel.unary_unary(
        '/jiji.rpc.BrokerService/GetAccount',
        request_serializer=broker__pb2.GetAccountRequest.SerializeToString,
        response_deserializer=broker__pb2.Account.FromString,
        )
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
    self.GetPositions = channel.unary_unary(
        '/jiji.rpc.BrokerService/GetPositions',
        request_serializer=broker__pb2.GetPositionsRequest.SerializeToString,
        response_deserializer=broker__pb2.Positions.FromString,
        )
    self.GetOrders = channel.unary_unary(
        '/jiji.rpc.BrokerService/GetOrders',
        request_serializer=broker__pb2.GetOrdersRequest.SerializeToString,
        response_deserializer=broker__pb2.Orders.FromString,
        )
    self.Order = channel.unary_unary(
        '/jiji.rpc.BrokerService/Order',
        request_serializer=broker__pb2.OrderRequest.SerializeToString,
        response_deserializer=broker__pb2.OrderResponse.FromString,
        )
    self.ModifyOrder = channel.unary_unary(
        '/jiji.rpc.BrokerService/ModifyOrder',
        request_serializer=broker__pb2.ModifyOrderRequest.SerializeToString,
        response_deserializer=broker__pb2.ModifyOrderResponse.FromString,
        )
    self.CancelOrder = channel.unary_unary(
        '/jiji.rpc.BrokerService/CancelOrder',
        request_serializer=broker__pb2.CancelOrderRequest.SerializeToString,
        response_deserializer=broker__pb2.CancelOrderResponse.FromString,
        )
    self.ModifyPosition = channel.unary_unary(
        '/jiji.rpc.BrokerService/ModifyPosition',
        request_serializer=broker__pb2.ModifyPositionRequest.SerializeToString,
        response_deserializer=broker__pb2.ModifyPositionResponse.FromString,
        )
    self.ClosePosition = channel.unary_unary(
        '/jiji.rpc.BrokerService/ClosePosition',
        request_serializer=broker__pb2.ClosePositionRequest.SerializeToString,
        response_deserializer=broker__pb2.ClosePositionResponse.FromString,
        )
    self.RetrieveEconomicCalendarInformations = channel.unary_unary(
        '/jiji.rpc.BrokerService/RetrieveEconomicCalendarInformations',
        request_serializer=broker__pb2.RetrieveEconomicCalendarInformationsRequest.SerializeToString,
        response_deserializer=broker__pb2.EconomicCalendarInformations.FromString,
        )


class BrokerServiceServicer(object):

  def GetAccount(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

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

  def GetPositions(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetOrders(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def Order(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ModifyOrder(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def CancelOrder(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ModifyPosition(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ClosePosition(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def RetrieveEconomicCalendarInformations(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_BrokerServiceServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'GetAccount': grpc.unary_unary_rpc_method_handler(
          servicer.GetAccount,
          request_deserializer=broker__pb2.GetAccountRequest.FromString,
          response_serializer=broker__pb2.Account.SerializeToString,
      ),
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
      'GetPositions': grpc.unary_unary_rpc_method_handler(
          servicer.GetPositions,
          request_deserializer=broker__pb2.GetPositionsRequest.FromString,
          response_serializer=broker__pb2.Positions.SerializeToString,
      ),
      'GetOrders': grpc.unary_unary_rpc_method_handler(
          servicer.GetOrders,
          request_deserializer=broker__pb2.GetOrdersRequest.FromString,
          response_serializer=broker__pb2.Orders.SerializeToString,
      ),
      'Order': grpc.unary_unary_rpc_method_handler(
          servicer.Order,
          request_deserializer=broker__pb2.OrderRequest.FromString,
          response_serializer=broker__pb2.OrderResponse.SerializeToString,
      ),
      'ModifyOrder': grpc.unary_unary_rpc_method_handler(
          servicer.ModifyOrder,
          request_deserializer=broker__pb2.ModifyOrderRequest.FromString,
          response_serializer=broker__pb2.ModifyOrderResponse.SerializeToString,
      ),
      'CancelOrder': grpc.unary_unary_rpc_method_handler(
          servicer.CancelOrder,
          request_deserializer=broker__pb2.CancelOrderRequest.FromString,
          response_serializer=broker__pb2.CancelOrderResponse.SerializeToString,
      ),
      'ModifyPosition': grpc.unary_unary_rpc_method_handler(
          servicer.ModifyPosition,
          request_deserializer=broker__pb2.ModifyPositionRequest.FromString,
          response_serializer=broker__pb2.ModifyPositionResponse.SerializeToString,
      ),
      'ClosePosition': grpc.unary_unary_rpc_method_handler(
          servicer.ClosePosition,
          request_deserializer=broker__pb2.ClosePositionRequest.FromString,
          response_serializer=broker__pb2.ClosePositionResponse.SerializeToString,
      ),
      'RetrieveEconomicCalendarInformations': grpc.unary_unary_rpc_method_handler(
          servicer.RetrieveEconomicCalendarInformations,
          request_deserializer=broker__pb2.RetrieveEconomicCalendarInformationsRequest.FromString,
          response_serializer=broker__pb2.EconomicCalendarInformations.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'jiji.rpc.BrokerService', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
