# coding: utf-8

module Jiji::Model::Agents::Internal
  class AgentFinder

    include Jiji::Model::Agents
    include Jiji::Errors

    def initialize(agents)
      @agents = agents
    end

    def each(&block)
      checked = Set.new
      @agents.values.each do |source|
        find_agent(source.name, source.context, checked) do |name|
          block.call(name)
        end
      end
    end

    def find_agent_class_by(name)
      not_found(Agent, name: name) unless name =~ /([^@]+)@([^@]+)$/

      class_path = Regexp.last_match(1)
      agent_name = Regexp.last_match(2)
      not_found(Agent, name => name) unless @agents.include? agent_name

      root = @agents[agent_name].context
      path = class_path.split('::')
      find_class_by(root, path, name)
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
          block.call("#{extract_name(cl.name)}@#{source_name}")
        end
        find_agent(source_name, cl, checked, &block) if cl.is_a?(Module)
      end
    end

    def extract_name(class_name)
      class_name.split('::', 2)[1]
    end

  end
end
