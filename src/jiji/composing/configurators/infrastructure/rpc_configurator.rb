# coding: utf-8

module Jiji::Composing::Configurators
  class RpcConfigurator < AbstractConfigurator

    include Jiji::Rpc

    def configure(container)
      container.configure do
        object :rpc_server, RpcServer.new
      end
    end

  end
end
