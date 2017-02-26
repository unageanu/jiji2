import grpc
from grpc.framework.common import cardinality
from grpc.framework.interfaces.face import utilities as face_utilities

import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import google.protobuf.empty_pb2 as google_dot_protobuf_dot_empty__pb2
import agent_pb2 as agent__pb2
import agent_pb2 as agent__pb2


class AgentServiceStub(object):

  def __init__(self, channel):
    """Constructor.

    Args:
      channel: A grpc.Channel.
    """
    self.NextTick = channel.unary_unary(
        '/jiji.rpc.AgentService/NextTick',
        request_serializer=agent__pb2.NextTickRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.Register = channel.unary_unary(
        '/jiji.rpc.AgentService/Register',
        request_serializer=agent__pb2.AgentSource.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.Unregister = channel.unary_unary(
        '/jiji.rpc.AgentService/Unregister',
        request_serializer=agent__pb2.AgentSourceName.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.GetAgentClasses = channel.unary_unary(
        '/jiji.rpc.AgentService/GetAgentClasses',
        request_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
        response_deserializer=agent__pb2.AgentClasses.FromString,
        )
    self.CreateAgentInstance = channel.unary_unary(
        '/jiji.rpc.AgentService/CreateAgentInstance',
        request_serializer=agent__pb2.AgentCreationRequest.SerializeToString,
        response_deserializer=agent__pb2.AgentCreationResult.FromString,
        )
    self.ExecPostCreate = channel.unary_unary(
        '/jiji.rpc.AgentService/ExecPostCreate',
        request_serializer=agent__pb2.ExecPostCreateRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.DeleteAgentInstance = channel.unary_unary(
        '/jiji.rpc.AgentService/DeleteAgentInstance',
        request_serializer=agent__pb2.AgentDeletionRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.GetAgentState = channel.unary_unary(
        '/jiji.rpc.AgentService/GetAgentState',
        request_serializer=agent__pb2.GetAgentStateRequest.SerializeToString,
        response_deserializer=agent__pb2.AgentState.FromString,
        )
    self.RestoreAgentState = channel.unary_unary(
        '/jiji.rpc.AgentService/RestoreAgentState',
        request_serializer=agent__pb2.RestoreAgentStateRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.SetAgentProperties = channel.unary_unary(
        '/jiji.rpc.AgentService/SetAgentProperties',
        request_serializer=agent__pb2.SetAgentPropertiesRequest.SerializeToString,
        response_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
        )
    self.SendAction = channel.unary_unary(
        '/jiji.rpc.AgentService/SendAction',
        request_serializer=agent__pb2.SendActionRequest.SerializeToString,
        response_deserializer=agent__pb2.SendActionResponse.FromString,
        )


class AgentServiceServicer(object):

  def NextTick(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def Register(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def Unregister(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetAgentClasses(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def CreateAgentInstance(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def ExecPostCreate(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def DeleteAgentInstance(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def GetAgentState(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def RestoreAgentState(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def SetAgentProperties(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')

  def SendAction(self, request, context):
    context.set_code(grpc.StatusCode.UNIMPLEMENTED)
    context.set_details('Method not implemented!')
    raise NotImplementedError('Method not implemented!')


def add_AgentServiceServicer_to_server(servicer, server):
  rpc_method_handlers = {
      'NextTick': grpc.unary_unary_rpc_method_handler(
          servicer.NextTick,
          request_deserializer=agent__pb2.NextTickRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'Register': grpc.unary_unary_rpc_method_handler(
          servicer.Register,
          request_deserializer=agent__pb2.AgentSource.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'Unregister': grpc.unary_unary_rpc_method_handler(
          servicer.Unregister,
          request_deserializer=agent__pb2.AgentSourceName.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'GetAgentClasses': grpc.unary_unary_rpc_method_handler(
          servicer.GetAgentClasses,
          request_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
          response_serializer=agent__pb2.AgentClasses.SerializeToString,
      ),
      'CreateAgentInstance': grpc.unary_unary_rpc_method_handler(
          servicer.CreateAgentInstance,
          request_deserializer=agent__pb2.AgentCreationRequest.FromString,
          response_serializer=agent__pb2.AgentCreationResult.SerializeToString,
      ),
      'ExecPostCreate': grpc.unary_unary_rpc_method_handler(
          servicer.ExecPostCreate,
          request_deserializer=agent__pb2.ExecPostCreateRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'DeleteAgentInstance': grpc.unary_unary_rpc_method_handler(
          servicer.DeleteAgentInstance,
          request_deserializer=agent__pb2.AgentDeletionRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'GetAgentState': grpc.unary_unary_rpc_method_handler(
          servicer.GetAgentState,
          request_deserializer=agent__pb2.GetAgentStateRequest.FromString,
          response_serializer=agent__pb2.AgentState.SerializeToString,
      ),
      'RestoreAgentState': grpc.unary_unary_rpc_method_handler(
          servicer.RestoreAgentState,
          request_deserializer=agent__pb2.RestoreAgentStateRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'SetAgentProperties': grpc.unary_unary_rpc_method_handler(
          servicer.SetAgentProperties,
          request_deserializer=agent__pb2.SetAgentPropertiesRequest.FromString,
          response_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
      ),
      'SendAction': grpc.unary_unary_rpc_method_handler(
          servicer.SendAction,
          request_deserializer=agent__pb2.SendActionRequest.FromString,
          response_serializer=agent__pb2.SendActionResponse.SerializeToString,
      ),
  }
  generic_handler = grpc.method_handlers_generic_handler(
      'jiji.rpc.AgentService', rpc_method_handlers)
  server.add_generic_rpc_handlers((generic_handler,))
