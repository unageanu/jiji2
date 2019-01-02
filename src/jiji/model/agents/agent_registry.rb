# frozen_string_literal: true

require 'encase'
require 'jiji/errors/errors'
require 'forwardable'

module Jiji::Model::Agents
  class AgentRegistry

    include Encase
    include Enumerable
    include Jiji::Errors
    extend Forwardable

    def_delegators :@builder,
      :create_agent, :get_agent_property_infos, :get_agent_description

    needs :agent_source_repository
    needs :time_source

    def initialize
      @mutex = Mutex.new
      @agents = {}
      Context._delegates = {}
      @finder  = Internal::AgentFinder.new(@agents)
      @builder = Internal::AgentBuilder.new(self)
    end

    def on_inject
      load_agent_sources
    end

    def each(&block)
      @finder.each(&block)
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

    def add_source(name, memo, type, body)
      @mutex.synchronize do
        already_exists(AgentSource, name: name) if @agents.include? name
        source = AgentSource.create(
          name, type, @time_source.now, memo, body)
        register_source(source)
        source
      end
    end

    def update_source(name, memo, body)
      @mutex.synchronize do
        not_found(AgentSource, name: name) unless @agents[name]
        @agents[name].update(name, @time_source.now, memo, body)
        Context._delegates[name] = @agents[name].context
        @agents[name]
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

    def get_agent_class(name)
      @mutex.synchronize do
        @finder.find_agent_class_by(name)
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
