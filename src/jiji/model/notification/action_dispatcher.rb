# coding: utf-8
require 'encase'

module Jiji::Model::Notification
  class ActionDispatcher

    include Encase
    include Jiji::Errors

    needs :rmt
    needs :backtest_repository

    def dispatch(backtest_id, agent_id, action)
      resolve_target(backtest_id).process.post_exec do |context, _queue|
        agent = context.agents[agent_id] \
             || not_found(Jiji::Model::Agents::Agent, agent_id: agent_id)
        agent.do_action(action)
      end
    end

    private

    def resolve_target(backtest_id)
      backtest_id.nil? ? rmt : backtest_repository.get(backtest_id)
    end

  end
end
