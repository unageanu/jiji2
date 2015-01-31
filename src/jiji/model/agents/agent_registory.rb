# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Agents 

  

  class AgentRegistry

    def initialize()
      @agent_dir = agent_dir
      @shared_lib_dir = shared_lib_dir
      @agents = {}
    end

    # エージェント名を列挙する
    def each( &block )
      checked = Set.new
      @agents.each() { |k,m|
        find_agent( k, m, checked ) {|name| block.call(name) }
      }
    end

    # エージェントを生成する
    def create(name, properties={})
      cl = get(name)
      safe( conf.get( [:agent,:safe_level], 4) ){
          agent = cl.new
          agent.properties = properties
          agent
      }
    end

    #エージェントを取得する
    #name:: エージェント名( @ )
    def get(name)
      unless name =~ /([^@]+)@([^@]+)/
        raise UserError.new( JIJI::ERROR_NOT_FOUND,
          "agent class not found. name=#{name}")
      end
      m = @agents["agents/#{$2}"]
      unless m
        raise UserError.new( JIJI::ERROR_NOT_FOUND,
          "agent class not found. name=#{name}")
      end

      path = $1.split("::")
      path.each {|step|
        unless m.const_defined? step
          raise UserError.new( JIJI::ERROR_NOT_FOUND,
            "agent class not found. name=#{name}")
        end
        m = m.const_get step
        unless m
          raise UserError.new( JIJI::ERROR_NOT_FOUND,
            "agent class not found. name=#{name}")
        end
        unless m.kind_of?(Module)
          raise UserError.new( JIJI::ERROR_NOT_FOUND,
            "agent class not found. name=#{name}")
        end
      }
      if m.kind_of?(Class) && m < JIJI::Agent
        m
      else
        raise UserError.new( JIJI::ERROR_NOT_FOUND,
          "agent class not found. name=#{name}")
      end
    end

    # エージェントのプロパティ一覧を取得する
    def get_property_infos(name)
      cl = get(name)
      return [] unless cl
      safe( conf.get( [:agent,:safe_level], 4) ){
        cl.new.property_infos
      }
    end

    # エージェントの説明を取得する
    def get_description(name)
      cl = get(name)
      return [] unless cl
      safe( conf.get( [:agent,:safe_level], 4) ){
        cl.new.description
      }
    end

    # エージェント置き場から、エージェントをロードする。
    # 起動時に一度だけ呼ばれる。
    def load_all
      [@agent_dir,@shared_lib_dir].each {|d|
        @file_dao.list( d, true ).each {|item|
          next if item[:type] == :directory
          begin
            inner_load( item[:path] )
          rescue Exception
            # ログ出力のみ行い、例外は握る。
            server_logger.error( $! )
          end
        }
      }
    end

    # 特定のファイルをロードする。
    def load(file)
      inner_load( file )
    end

    # 特定のファイルをアンロードする。
    def unload(file)
      if file =~ /^#{@agent_dir}\/.*/
        @agents.delete file
      else
        JIJI::Agent::Shared._delegates.delete file
      end
    end

    attr :conf, true
    attr :file_dao, true
    attr :server_logger, true
  private

    def inner_load( file )
      body = @file_dao.get(file).taint
      m = Module.new.taint
      if file =~ /^#{@agent_dir}\/.*/
        @agents[ file ] = m
      elsif file =~ /^#{@shared_lib_dir}\/.*/
        JIJI::Agent::Shared._delegates[ file ] = m
      else
        return # agent,shared_lib配下のファイル以外は読み込まない。
      end
      safe( conf.get( [:agent,:safe_level], 4) ){
        m.module_eval( body, file, 1 )
      }
    end

    def find_agent( file, m, checked, &block )
      return if checked.include? m
      checked << m
      m.constants.each {|name|
        cl = m.const_get name
        agent_file = file.sub( /^#{@agent_dir}\/?/, "" )
        begin
          block.call( "#{get_name(cl.name)}@#{agent_file}" ) if cl.kind_of?(Class) && cl < JIJI::Agent
        rescue Exception
        end
        find_agent( file, cl, checked, &block ) if cl.kind_of?(Module)
      }
    end
    def get_name( name )
      name.split("::", 2)[1]
    end

  end

end
end
end