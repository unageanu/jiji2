require 'grpc'
require 'singleton'
require 'health_check_services_pb'

module Jiji
  class RpcClient

    SERVER_URL = 'localhost:50051'.freeze

    include Singleton

    def agent_service
      Jiji::Rpc::AgentService::Stub.new(
        SERVER_URL, :this_channel_is_insecure)
    end

    def health_check_service
      Jiji::Rpc::HealthCheckService::Stub.new(
        SERVER_URL, :this_channel_is_insecure)
    end

    def wait_for_server_start_up
      service = health_check_service
      puts 'wait for server start up.'
      loop do
        begin
          service.status(Google::Protobuf::Empty.new)
          return
        rescue GRPC::BadStatus => e
          if e.code == 14
            puts ' sleep 5 seconds...'
            sleep 5
          else
            raise e
          end
        end
      end
    end

  end
end
