# coding: utf-8

module Jiji::Model::Agents::Internal
  class AgentFinder

    include Jiji::Model::Agents
    include Jiji::Errors

    NAME_REGEXP = /([^@]+)@([^@]+)$/

    def each(&block)
      checked = Set.new
      Context._delegates.each do |source_name, context|
        find_agent(source_name, context, checked) do |name, cl|
          yield(name, cl)
        end
      end
    end

    def find_agent_class_by(name)
      agents = Context._delegates
      steps = AgentFinder.split_class_name(name)
      class_path = steps[0]
      agent_name = steps[1]
      not_found(Agent, name => name) unless agents.include? agent_name

      root = agents[agent_name]
      path = class_path.split('::')
      find_class_by(root, path, name)
    end

    def self.split_class_name(name)
      not_found(Agent, name: name) unless name =~ NAME_REGEXP

      class_path = Regexp.last_match(1)
      agent_name = Regexp.last_match(2)
      [class_path, agent_name]
    end

    private

    def find_class_by(root, path, name)
      mod = root
      path.each do |step|
        not_found(Agent, name: name) unless check_object_is(mod, Module)
        not_found(Agent, name: name, step: step) unless mod.const_defined? step

        mod = mod.const_get step
      end
      unless check_object_is(mod, Class) && mod < Agent
        not_found(Agent, name => name)
      end
      mod
    end

    def check_object_is(o, type)
      !o.nil? && o.is_a?(type)
    end

    def find_agent(source_name, m, checked, &block)
      return if checked.include? m
      return unless m
      checked << m

      m.constants.each do |name|
        cl = m.const_get name
        if cl.is_a?(Class) && cl < Jiji::Model::Agents::Agent
          yield("#{extract_name(cl.name)}@#{source_name}", cl)
        end
        find_agent(source_name, cl, checked, &block) if cl.is_a?(Module)
      end
    end

    def extract_name(class_name)
      class_name.split('::', 2)[1]
    end

  end
end
