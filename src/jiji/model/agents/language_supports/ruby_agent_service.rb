# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'forwardable'

module Jiji::Model::Agents::LanguageSupports
  class RubyAgentService

    include Jiji::Model::Agents

    def initialize
      Context._delegates = {}
      @finder = Internal::AgentFinder.new
    end

    def available?
      true
    end

    def register_source(agent_source)
      Context._delegates[agent_source.name] = evaluate(agent_source)
    end

    def unregister_source(name)
      Context._delegates.delete name
    end

    def retrieve_agent_classes(&block)
      @finder.each do |name, cl|
        yield({
          name:        name,
          description: cl.respond_to?(:description) ? cl.description : nil,
          properties:  cl.respond_to?(:property_infos) ? cl.property_infos : []
        })
      end
    end

    def create_agent_instance(name, properties)
      cl = get_agent_class(name)
      agent = cl.new
      agent.properties = properties
      agent
    end

    def delete_agent_instance
    end

    def evaluate(agent_source)
      if agent_source.body.nil? || agent_source.body.empty?
        agent_source.change_state_to_empty
        nil
      else
        context = Context.new_context
        evaluate_agent_source(agent_source, context)
        context
      end
    end

    def evaluate_agent_source(agent_source, context)
      context.module_eval(agent_source.body,
        "#{agent_source.type}/#{agent_source.name}", 1)
      agent_source.change_state_to_normal
    rescue Exception => e # rubocop:disable Lint/RescueException
      agent_source.change_state_to_error(e)
    end

    private

    def get_agent_class(name)
      @finder.find_agent_class_by(name)
    end

  end
end
