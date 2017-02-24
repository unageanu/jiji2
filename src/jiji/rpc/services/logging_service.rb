# coding: utf-8

require 'grpc'
require 'logging_pb'
require 'logging_services_pb'
require 'jiji/rpc/services/rpc_service_mixin'

module Jiji::Rpc::Services
  class LoggingService < Jiji::Rpc::LoggerService::Service

    include Encase
    include RpcServiceMixin

    needs :agent_proxy_pool

    def log(request, call)
      agent = get_agent_instance(request.instance_id)
      agent.logger.log(resolve_log_level(request.log_level), request.message)
      Google::Protobuf::Empty.new
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Google::Protobuf::Empty.new
    end

    def resolve_log_level(log_level)
      if log_level && !log_level.empty? \
        && Logger::Severity.const_defined?(log_level)
        Logger::Severity.const_get(log_level)
      else
        Logger::Severity::UNKNOWN
      end
    end

  end
end
