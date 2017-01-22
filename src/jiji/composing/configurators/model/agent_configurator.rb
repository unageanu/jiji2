# coding: utf-8

module Jiji::Composing::Configurators
  class AgentConfigurator < AbstractConfigurator

    include Jiji::Model::Agents
    include Jiji::Model::Agents::LanguageSupports

    def configure(container)
      configure_agent_service_components(container)
      configure_agent_components(container)
    end

    def configure_agent_components(container)
      container.configure do
        object :agent_builder,           Internal::AgentBuilder.new

        object :agent_source_repository, AgentSourceRepository.new
        object :agent_registry,          AgentRegistry.new
      end
    end

    def configure_agent_service_components(container)
      container.configure do
        object :ruby_agent_service,     RubyAgentService.new
        object :python_agent_service,   PythonAgentService.new

        object :agent_service_resolver, AgentServiceResolver.new
        object :agent_proxy_pool,       AgentProxyPool.new
      end
    end

  end
end
