# coding: utf-8

require 'grpc'
require 'logging_pb'
require 'logging_services_pb'

module Jiji::Rpc::Services
  class LoggingService < Jiji::Rpc::LoggerService::Service

    def log(request, context)
      p request
      Google::Protobuf::Empty.new
    end

  end
end
