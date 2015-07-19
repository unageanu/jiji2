# coding: utf-8

require 'encase'
require 'set'

module Jiji::Model::Agents
  class AgentsUpdater

    include Jiji::Model::Trading::Brokers
    include Jiji::Model::Notification

    def initialize(backtest_id, agent_registory, broker, graph_factory,
      push_notifier, mail_composer, time_source, logger)
      @backtest_id     = backtest_id
      @agent_registory = agent_registory
      @broker          = broker
      @graph_factory   = graph_factory
      @push_notifier   = push_notifier
      @mail_composer   = mail_composer
      @time_source     = time_source
      @logger          = logger
    end

    def update(agents, agent_setting, fail_on_error = false)
      new_agents = agent_setting.each_with_object({}) do |setting, r|
        begin
          create_or_update_agent(r, setting, agents)
        rescue Exception => e # rubocop:disable Lint/RescueException
          @logger.error(e) if @logger
          raise e if fail_on_error
        end
      end
      agents.agents = new_agents
    end

    private

    def create_or_update_agent(r, setting, agents)
      uuid = setting[:uuid]
      if agents.include?(uuid)
        r[uuid] = update_agent(agents[uuid], setting)
      else
        r[uuid] = create_agent(setting, uuid)
      end
    end

    def update_agent(agent, setting)
      agent.properties = setting[:properties]
      agent
    end

    def create_agent(setting, uuid)
      agent = @agent_registory.create_agent(
        setting[:agent_class], setting[:properties] || {})
      agent.agent_name  = setting[:agent_name] || setting[:agent_class]
      inject_components_to(agent, uuid)
      agent.post_create
      agent
    end

    def inject_components_to(agent, agent_id)
      agent_name = agent.agent_name
      broker = BrokerProxy.new(@broker, agent_name, agent_id)

      agent.broker          = broker
      agent.graph_factory   = @graph_factory
      agent.notifier        = create_notificator(agent_id, agent_name)
      agent.logger          = @logger
    end

    def create_notificator(agent_id, agent_name)
      Notificator.new(@backtest_id, agent_id,
        agent_name, @push_notifier, @mail_composer, @time_source)
    end

  end
end
