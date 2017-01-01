require 'grpc'
require 'singleton'
require 'agent_services_pb'

module Jiji
  class RpcClient

    include Singleton

    def agent_service
      Jiji::Rpc::AgentService::Stub.new(
        'localhost:50051', :this_channel_is_insecure)
    end

    def wait_for_server_start_up
      service = agent_service
      puts 'wait for server start up.'
      loop do
        begin
          service.get_agent_classes(Google::Protobuf::Empty.new)
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
