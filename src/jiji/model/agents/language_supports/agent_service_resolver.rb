# coding: utf-8
require 'encase'

module Jiji::Model::Agents::LanguageSupports
  class AgentServiceResolver

    include Encase

    needs :ruby_agent_service
    needs :python_agent_service

    def resolve(language)
      return services[language.to_sym] if services.include? language.to_sym
      ruby_agent_service
    end

    def available_languages
      services.keys.reject do |k|
        !services[k].available?
      end
    end

    def services
      @services ||= {
        python: python_agent_service,
        ruby:   ruby_agent_service
      }
    end

  end
end
