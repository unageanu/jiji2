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
      @finder = Internal::AgentFinder.new(@agents)
    end

    def on_inject
      load_agent_sources
    end

    def each(&block)
      @finder.each(&block)
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
        register_source(source)
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
        unregister_source(name)
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
        @finder.find_agent_class_by(name)
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

    def load_agent_sources
      load(@agent_source_repository.all)
    end

    def load(sources)
      # エラーになったものを再ロードする。
      # エラーがなくなる or すべてエラーになるまで繰り返し、依存関係によるエラーを解消する。
      failed = []
      sources.each do |source|
        source.evaluate
        register_source(source)

        failed << source if source.status == :error
      end
      return if failed.empty?
      return if failed.length == sources.length # すべてエラーならこれ以上リトライしない
      load(failed)
    end

    def register_source(source)
      @agents[source.name] = source
      Context._delegates[source.name] = source.context
    end

    def unregister_source(name)
      @agents.delete name
      Context._delegates.delete name
    end

  end
end
