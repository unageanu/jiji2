# coding: utf-8

require 'encase'
require 'jiji/errors/errors'

module Jiji
module Model
module Agents 

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
    
    def each( &block )
      checked = Set.new
      agent_sources.each { |source|
        find_agent( source.name, source.context, checked ) {|name| 
          block.call(name) 
        }
      }
    end
    
    def agent_sources
      @mutex.synchronize {
        @agents.values
      }
    end
    
    def add_source( name, memo, type, body )
      @mutex.synchronize {
        already_exists(AgentSource, :name=>name) if @agents.include? name
        source = AgentSource.create( name, 
          type, @time_source.now, memo, body)
        @agents[source.name] = source
        Context._delegates[source.name] = source.context
      }
    end
    
    def update_source( name, memo, body )
      @mutex.synchronize {
        not_found(AgentSource, :name=>name) unless @agents[name]
        @agents[name].update( name, @time_source.now, memo, body )
        Context._delegates[name] = @agents[name].context
      }
    end
    
    def remove_source( name )
      @mutex.synchronize {
        not_found(AgentSource, :name=>name) unless @agents[name]
        @agents[name].delete
        @agents.delete name
        Context._delegates.delete name
      }
    end
    
    def create_agent(name, properties={})
      cl = get_agent_class(name)
      agent = cl.new
      agent.properties = properties
      agent
    end

    def get_agent_class(name)
      @mutex.synchronize {
        not_found(Agent,name=>name) unless name =~ /([^@]+)@([^@]+)$/
        not_found(Agent,name=>name) unless @agents.include? $2
        
        mod = @agents[$2].context
        path = $1.split("::")
        path.each {|step|
          not_found(Agent,:name=>name) if mod == nil || !mod.kind_of?(Module)
          not_found(Agent,:name=>name,:step=>step) unless mod.const_defined? step
  
          mod = mod.const_get step
        }
        unless mod != nil && mod.kind_of?(Class) && mod < Jiji::Model::Agents::Agent
          not_found(Agent,name=>name) 
        end
        return mod
      }
    end

    def get_agent_property_infos(name)
      cl = get_agent_class(name)
      cl.respond_to?( :property_infos ) ? cl.property_infos : []
    end

    def get_agent_description(name)
      cl = get_agent_class(name)
      cl.respond_to?( :description ) ? cl.description : nil
    end
    
  private
    
    def load_agent_sources
      load(@agent_source_repository.get_all)
    end
    def load( sources )
      # エラーになったものを再ロードする。
      # エラーがなくなる or すべてエラーになるまで繰り返し、依存関係によるエラーを解消する。
      failed = []
      sources.each {|source|
        source.evaluate
        @agents[source.name] = source
        Context._delegates[source.name] = source.context
        
        if source.status == :error
          failed << source
        end
      }
      return if failed.empty?
      return if failed.length == sources.length # すべてエラーならこれ以上リトライしない
      load( failed )
    end
    
    def find_agent( source_name, m, checked, &block )
      return if checked.include? m
      checked << m
      
      m.constants.each {|name|
        cl = m.const_get name
        if cl.kind_of?(Class) && cl < Jiji::Model::Agents::Agent
          block.call( "#{extract_name(cl.name)}@#{source_name}" )
        end
        if cl.kind_of?(Module)
          find_agent( source_name, cl, checked, &block ) 
        end
      }
    end
    def extract_name(class_name)
      class_name.split("::", 2)[1]
    end

  end

end
end
end