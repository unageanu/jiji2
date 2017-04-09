# coding: utf-8

require 'grpc'
require 'broker_pb'
require 'broker_services_pb'
require 'jiji/rpc/services/rpc_service_mixin'
require 'jiji/rpc/converters'

module Jiji::Rpc::Services
  class BrokerService < Jiji::Rpc::BrokerService::Service

    include Encase
    include Jiji::Rpc::Converters
    include RpcServiceMixin

    needs :agent_proxy_pool

    def get_pairs(request, call)
      agent = get_agent_instance(request.instance_id)
      Jiji::Rpc::GetPairsResponse.new(pairs:convert_pairs(agent.broker.pairs))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::GetPairsResponse.new(pairs:[])
    end

    def get_tick(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_tick(agent.broker.tick)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Tick.new(values:[], timestamp:nil)
    end

    def retrieve_rates(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_rates(agent.broker.retrieve_rates(request.pair_name.to_sym,
        request.interval.to_sym, Time.at(request.start_time.seconds),
        Time.at(request.end_time.seconds)))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Rates.new(rate:[])
    end

  end
end
