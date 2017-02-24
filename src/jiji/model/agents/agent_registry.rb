# coding: utf-8

require 'encase'
require 'jiji/errors/errors'

module Jiji::Model::Agents
  class AgentRegistry

    include Encase
    include Enumerable
    include Jiji::Errors

    needs :agent_source_repository
    needs :agent_builder
    needs :agent_service_resolver
    needs :time_source

    def initialize
      @mutex = Mutex.new
      @agents = {}
    end

    def on_inject
      load_agent_sources
    end

    def create_agent(class_name, agent_name, properties = {})
      @mutex.synchronize do
        agent_builder.create_agent(class_name, agent_name, properties, @agents)
      end
    end

    def each(&block)
      agent_service_resolver.available_services.each do |service|
        service.retrieve_agent_classes(&block)
      end
    end

    def find_agent_source_by_id(id)
      @mutex.synchronize do
        @agents.values.find { |a| a._id == id } \
          || not_found(AgentSource, name: id)
      end
    end

    def find_agent_source_by_name(name)
      @mutex.synchronize do
        @agents[name] || not_found(AgentSource, name: name)
      end
    end

    def agent_sources
      @mutex.synchronize { @agents.values }
    end

    def add_source(name, memo, type, body, language = 'ruby')
      @mutex.synchronize do
        already_exists(AgentSource, name: name) if @agents.include? name
        source = AgentSource.create(name, type,
          @time_source.now, memo, body, language)
        register_source(source)
      end
    end

    def update_source(name, memo, body, language = 'ruby')
      @mutex.synchronize do
        not_found(AgentSource, name: name) unless @agents[name]
        source = @agents[name]
        source.update(name, @time_source.now, memo, body, language)
        register_source(source)
      end
    end

    def remove_source(name)
      @mutex.synchronize do
        not_found(AgentSource, name: name) unless @agents[name]
        @agents[name].delete
        unregister_source(name)
      end
    end

    def rename_source(old_name, new_name)
      return if old_name == new_name
      @mutex.synchronize do
        not_found(AgentSource, name: old_name) unless @agents[old_name]
        already_exists(AgentSource, name: new_name) if @agents[new_name]
        source = @agents[old_name]
        unregister_source(old_name)
        source.update(new_name, @time_source.now)
        register_source(source)
      end
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
        register_source(source)
        source.save

        failed << source if source.status == :error
      end
      return if failed.empty?
      return if failed.length == sources.length # すべてエラーならこれ以上リトライしない
      load(failed)
    end

    def register_source(source)
      agent_service_resolver.resolve(source.language).register_source(source)
      @agents[source.name] = source
      source.save
      source
    end

    def unregister_source(name)
      source = @agents[name]
      agent_service_resolver.resolve(source.language) \
        .unregister_source(source.name)
      @agents.delete name
    end

  end
end
