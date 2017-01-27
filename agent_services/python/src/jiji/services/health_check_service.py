from datetime import datetime

import health_check_pb2
import health_check_pb2_grpc
from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module

from jiji.services.abstract_service import AbstractService

class HealthCheckService(AbstractService, health_check_pb2_grpc.HealthCheckServiceServicer):

    def Status(self, request, context):
        return health_check_pb2.GetStatusResponse(status="OK")
