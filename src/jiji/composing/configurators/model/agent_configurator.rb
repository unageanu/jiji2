# frozen_string_literal: true

module Jiji::Composing::Configurators
  class AgentConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      container.configure do
        object :agent_source_repository,  Agents::AgentSourceRepository.new
        object :agent_registry,           Agents::AgentRegistry.new
      end
    end

  end
end
