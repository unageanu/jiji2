# coding: utf-8

require 'encase'
require 'jiji/errors/errors'

module Jiji::Model::Agents
  class AgentRegistry
    include Encase
    include Enumerable
    include Jiji::Errors

    needs :agent_source_repository
    needs :time_source

    def initialize
      @mutex = Mutex.new
      @agents = {}
      Context._delegates = {}
    end

    def on_inject
      load_agent_sources
    end

    def each(&block)
      checked = Set.new
      agent_sources.each do |source|
        find_agent(source.name, source.context, checked) do|name|
          block.call(name)
        end
      end
    end

    def agent_sources
      @mutex.synchronize do
        @agents.values
      end
    end

    def add_source(name, memo, type, body)
      @mutex.synchronize do
        already_exists(AgentSource, name: name) if @agents.include? name
        source = AgentSource.create(
          name, type, @time_source.now, memo, body)
        @agents[source.name] = source
        Context._delegates[source.name] = source.context
      end
    end

    def update_source(name, memo, body)
      @mutex.synchronize do
        not_found(AgentSource, name: name) unless @agents[name]
        @agents[name].update(name, @time_source.now, memo, body)
        Context._delegates[name] = @agents[name].context
      end
    end

    def remove_source(name)
      @mutex.synchronize do
        not_found(AgentSource, name: name) unless @agents[name]
        @agents[name].delete
        @agents.delete name
        Context._delegates.delete name
      end
    end

    def create_agent(name, properties = {})
      cl = get_agent_class(name)
      agent = cl.new
      agent.properties = properties
      agent
    end

    def get_agent_class(name)
      @mutex.synchronize do
        not_found(Agent, name => name) unless name =~ /([^@]+)@([^@]+)$/

        class_path = Regexp.last_match(1)
        agent_name = Regexp.last_match(2)
        not_found(Agent, name => name) unless @agents.include? agent_name

        root = @agents[agent_name].context
        path = class_path.split('::')
        return find_class_by(root, path, name)
      end
    end

    def get_agent_property_infos(name)
      cl = get_agent_class(name)
      cl.respond_to?(:property_infos) ? cl.property_infos : []
    end

    def get_agent_description(name)
      cl = get_agent_class(name)
      cl.respond_to?(:description) ? cl.description : nil
    end

    private

    def find_class_by(root, path, name)
      mod = root
      path.each do|step|
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

    def load_agent_sources
      load(@agent_source_repository.all)
    end

    def load(sources)
      # エラーになったものを再ロードする。
      # エラーがなくなる or すべてエラーになるまで繰り返し、依存関係によるエラーを解消する。
      failed = []
      sources.each do|source|
        source.evaluate
        @agents[source.name] = source
        Context._delegates[source.name] = source.context

        failed << source if source.status == :error
      end
      return if failed.empty?
      return if failed.length == sources.length # すべてエラーならこれ以上リトライしない
      load(failed)
    end

    def find_agent(source_name, m, checked, &block)
      return if checked.include? m
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
