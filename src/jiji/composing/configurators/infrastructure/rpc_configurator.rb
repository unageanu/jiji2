# coding: utf-8

module Jiji::Composing::Configurators
  class RpcConfigurator < AbstractConfigurator

    include Jiji::Rpc

    def configure(container)
      container.configure do
        object :rpc_server, RpcServer.new

        object :logging_service,      Services::LoggingService.new
        object :health_check_service, Services::HealthCheckService.new
      end
    end

  end
end
