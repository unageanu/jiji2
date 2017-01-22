# coding: utf-8

require 'encase'

module Jiji::Model::Agents::Internal
  class AgentsUpdater

    include Jiji::Model::Agents
    include Jiji::Model::Trading::Brokers
    include Jiji::Model::Notification

    def initialize(backtest, agent_registry, components)
      @backtest        = backtest
      @agent_registry  = agent_registry
      @components      = components
    end

    def update(agents, new_agent_setting, fail_on_error = false)
      settings = []
      after = new_agent_setting.each_with_object({}) do |s, r|
        settings << s = AgentSetting.get_or_create_from_hash(s, backtest_id)
        process_error(!fail_on_error) do
          r[s.id] = create_or_update_agent(agents, s)
        end
      end
      settings.each { |s| s.save }
      deactivate_removed_agents(after, agents)
      after
    end

    def restore_agents_from_saved_state
      AgentSetting.load(backtest_id).each_with_object({}) do |setting, r|
        process_error { r[setting.id] = create_agent(setting) }
      end
    end

    def save_state(agents)
      AgentSetting.load(backtest_id).each do |setting|
        agent = agents[setting.id]
        next unless agent
        process_error do
          setting.state = agent.state
          setting.save
        end
      end
    end

    private

    def deactivate_removed_agents(after, before)
      destroy_removed_agents(after, before)
      AgentSetting.load(backtest_id).each do |setting|
        setting.active = after.include?(setting.id)
        setting.save
      end
    end

    def destroy_removed_agents(after, before)
      (before.keys - after.keys).each do |key|
        agent = before[key]
        process_error(true) { agent.destroy }
      end
    end

    def create_or_update_agent(agents, setting)
      if agents.include?(setting.id)
        update_agent(agents[setting.id], setting)
      else
        create_agent(setting)
      end
    end

    def update_agent(agent, setting)
      agent.properties = setting.properties_with_indifferent_access
      agent.agent_name = setting.name
      agent
    end

    def create_agent(setting)
      agent = @agent_registry.create_agent(
        setting.agent_class, setting.properties_with_indifferent_access)
      agent.agent_name = setting.name || setting.agent_class
      inject_components_to(agent, setting)
      agent.post_create
      restore_state(agent, setting)
      agent
    end

    def inject_components_to(agent, setting)
      broker = BrokerProxy.new(@components[:broker], setting)

      agent.broker          = broker
      agent.graph_factory   = @components[:graph_factory]
      agent.notifier        = create_notificator(setting)
      agent.logger          = @components[:logger]
    end

    def create_notificator(agent)
      Notificator.new(@backtest, agent, @components[:push_notifier],
        @components[:mail_composer], @components[:time_source],
        @components[:logger])
    end

    def restore_state(agent, setting)
      state = setting.state_with_indifferent_access
      return unless state
      process_error { agent.restore_state(state) if agent }
    end

    def process_error(ignore = true)
      yield
    rescue Exception => e # rubocop:disable Lint/RescueException
      log(e)
      raise e unless ignore
    end

    def backtest_id
      @backtest ? @backtest.id : nil
    end

    def log(error)
      @components[:logger].error(error) if @components[:logger]
    end

  end
end
