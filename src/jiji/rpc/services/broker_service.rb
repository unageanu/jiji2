# coding: utf-8

require 'grpc'
require 'broker_pb'
require 'broker_services_pb'
require 'jiji/rpc/services/rpc_service_mixin'

module Jiji::Rpc::Services
  module OrderFunctions
    def get_orders(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_orders_to_pb(agent.broker.orders)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Orders.new(orders: [])
    end

    def order(request, call)
      agent = get_agent_instance(request.instance_id)
      order_option = convert_order_options_from_pb(request.option)
      result = do_order(request, agent, order_option)
      convert_order_result_to_pb(result)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      create_empty_order_result
    end

    def modify_order(request, call)
      agent = get_agent_instance(request.instance_id)
      modified_order = agent.broker.modify_order(
        convert_order_from_pb(request.modified_order))
      Jiji::Rpc::ModifyOrderResponse.new(
        modified_order: convert_order_to_pb(modified_order))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::ModifyOrderResponse.new(modified_order: nil)
    end

    def cancel_order(request, call)
      agent = get_agent_instance(request.instance_id)
      cancelled_order = agent.broker.cancel_order({
        internal_id: request.order_id
      })
      Jiji::Rpc::CancelOrderResponse.new(
        cancelled_order: convert_order_to_pb(cancelled_order))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::CancelOrderResponse.new(cancelled_order: nil)
    end

    private

    def do_order(request, agent, order_option)
      broker = agent.broker
      pair = request.pair_name.to_sym
      type = request.type.to_sym
      if request.sell_or_buy == 'sell'
        broker.sell(pair, request.units, type, order_option)
      else
        broker.buy(pair, request.units, type, order_option)
      end
    end

    def create_empty_order_result
      Jiji::Rpc::OrderResponse.new({
        order_opened:  nil,
        trade_opened:  nil,
        trade_reduced: nil,
        trades_closed: []
      })
    end
  end

  module PositionFunctions
    def get_positions(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_positions_to_pb(agent.broker.positions)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Positions.new(positions: [])
    end

    def modify_position(request, call)
      agent = get_agent_instance(request.instance_id)
      modified_position = agent.broker.modify_position(
        convert_position_from_pb(request.modified_position))
      Jiji::Rpc::ModifyPositionResponse.new(
        modified_position: convert_position_to_pb(modified_position))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::ModifyPositionResponse.new(modified_position: nil)
    end

    def close_position(request, call)
      agent = get_agent_instance(request.instance_id)
      closed_position = agent.broker.close_position({
        internal_id: request.position_id
      })
      Jiji::Rpc::ClosePositionResponse.new(
        closed_position: convert_position_to_pb(closed_position))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::ClosePositionResponse.new(closed_position: nil)
    end
  end

  class BrokerService < Jiji::Rpc::BrokerService::Service

    include Encase
    include RpcServiceMixin
    include OrderFunctions
    include PositionFunctions

    needs :agent_proxy_pool

    def get_pairs(request, call)
      agent = get_agent_instance(request.instance_id)
      Jiji::Rpc::GetPairsResponse.new(
        pairs: convert_pairs_to_pb(agent.broker.pairs))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::GetPairsResponse.new(pairs: [])
    end

    def get_tick(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_tick_to_pb(agent.broker.tick)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Tick.new(values: [], timestamp: nil)
    end

    def retrieve_rates(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_rates_to_pb(do_retrieve_rates(request, agent))
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      create_empty_rates
    end

    def retrieve_economic_calendar_informations(request, call)
      agent = get_agent_instance(request.instance_id)
      informations = agent.broker.retrieve_economic_calendar_informations(
        request.period, request.pair_name.to_sym)
      convert_economic_calendar_informations_to_pb(informations)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::EconomicCalendarInformations.new(informations: [])
    end

    def get_account(request, call)
      agent = get_agent_instance(request.instance_id)
      convert_account_to_pb(agent.broker.account)
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_exception(e, call)
      return Jiji::Rpc::Account.new
    end

    private

    def do_retrieve_rates(request, agent)
      agent.broker.retrieve_rates(
        request.pair_name.to_sym,
        request.interval.to_sym,
        convert_timestamp_from_pb(request.start_time),
        convert_timestamp_from_pb(request.end_time))
    end

    def create_empty_rates
      Jiji::Rpc::Rates.new(rates: [])
    end

  end
end
