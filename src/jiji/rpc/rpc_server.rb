# coding: utf-8

require 'grpc'
require 'encase'
require 'jiji/rpc/services/logging_service'
require 'jiji/rpc/services/health_check_service'

module Jiji::Rpc
  class RpcServer

    include Encase

    needs :logging_service
    needs :health_check_service

    def start
      @server = GRPC::RpcServer.new
      @server.add_http2_port(bind_address, :this_port_is_insecure)
      register_services(@server)

      Thread.new(@server) do |server|
        server.run
      end
    end

    def stop
      @server.stop if @server
    end

    private

    def bind_address
      "0.0.0.0:#{ENV['RPC_PORT'] || 50_052}"
    end

    def register_services(server)
      server.handle(logging_service)
      server.handle(health_check_service)
    end

  end
end
