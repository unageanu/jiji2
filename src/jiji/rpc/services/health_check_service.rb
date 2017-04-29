# coding: utf-8

require 'grpc'
require 'health_check_pb'
require 'health_check_services_pb'
require 'jiji/rpc/services/rpc_service_mixin'

module Jiji::Rpc::Services
  class HealthCheckService < Jiji::Rpc::HealthCheckService::Service

    include Encase
    include RpcServiceMixin

    def status(request, call)
      Jiji::Rpc::GetStatusResponse.new(status: 'OK')
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Google::Protobuf::Empty.new
    end

  end
end
