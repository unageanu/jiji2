# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji
module Model
module Agents 

  module Agent
    
    #====設定可能なプロパティの一覧を返します。
    #必要に応じてオーバーライドしてください。
    #戻り値:: JIJI::Agent::Propertyの配列
    def self.property_infos
      []
    end
    
    #====エージェントの説明を返します。
    #必要に応じてオーバーライドしてください。
    def self.description
      ""
    end
    
    
    #====設定されたプロパティを取得します。
    def properties
      @properties
    end    
    #====プロパティを設定します。
    def properties=( properties )
      @properties = properties
      properties.each_pair {|k,v|
        instance_variable_set("@#{k}", v)
      }
    end
    
    #====エージェントの登録後に1度だけ呼び出される関数。
    #必要に応じてオーバーライドしてください。コンストラクタと違い、
    #このメソッドではoperatorやoutput,loggerが使用可能です。
    def init
    end
    
    #====レート情報が通知されるメソッドです。
    #エージェントが動作している間順次呼び出されます。 
    #このメソッドをオーバーライドして、シグナルの計算や
    #取り引きを行うロジックを実装してください
    #rates:: JIJI::Rates
    def next_tick( broker )
    end
    
    def save_state
    end
    
    def restore_state(state)
    end
    
    
    #===エージェントのプロパティ
    class Property
      
      include Jiji::Utils::ValueObject
      include Jiji::Web::Transport::Transportable
      
      #====コンストラクタ
      #id:: プロパティID
      #name:: UIでの表示名
      #default_value:: プロパティの初期値
      #type:: 種類
      def initialize( id, name, default_value=nil, type=:string )
        @id = id
        @name = name
        @default = default_value
        @type = type
      end
      #プロパティID。
      #JIJI::Agent#properties=(props)で渡されるハッシュのキーになります。設定必須です。
      attr :id, true
      # UIでの表示名。設定必須です。
      attr :name, true
      # プロパティの初期値。
      attr :default, true
      # 種類。:string or :numberが指定可能。指定しない場合、:stringが指定されたものとみなされます。
      attr :type, true
      
      def values
        [id, name, type, default]
      end
      def to_h # nodoc
        {:id =>id, :name=> name, :type=>type, :default=>default}
      end
    end
    
  end

end
end
end