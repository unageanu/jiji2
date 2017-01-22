# coding: utf-8

module Jiji::Model::Agents::LanguageSupports
  class AgentProxyPool

    def initialize
      @pool = {}
    end

    def []=(instance_id, instance)
      @pool[instance_id] = instance
    end

    def [](instance_id)
      @pool[instance_id]
    end

  end
end
