# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Agents::Agent
  #====設定可能なプロパティの一覧を返します。
  # 必要に応じてオーバーライドしてください。
  # 戻り値:: Jiji::Agent::Propertyの配列
  def self.property_infos
    []
  end

  #====エージェントの説明を返します。
  # 必要に応じてオーバーライドしてください。
  def self.description
    ''
  end

  #====設定されたプロパティを取得します。
  attr_reader :properties

  #====プロパティを設定します。
  def properties=(properties)
    @properties = properties
    properties.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  attr_accessor :broker
  attr_accessor :graph_factory
  attr_accessor :notifier
  attr_accessor :logger

  #====エージェントの登録後に1度だけ呼び出される関数。
  # 必要に応じてオーバーライドしてください。コンストラクタと違い、
  # このメソッド内ではbrokerやgraph_factory,logger等が使用可能です。
  def post_create
  end

  #====レート情報が通知されるメソッドです。
  # エージェントが動作している間順次呼び出されます。
  # このメソッドをオーバーライドして、シグナルの計算や
  # 取り引きを行うロジックを実装してください
  # tick:: Jiji::Model::Trading::Tick
  def next_tick(_tick)
  end

  #====アクションを実行します。
  # 必要に応じてオーバーライドしてください。
  def do_action(action_name)
  end

  #====エージェントの状態を返します。
  def state
  end

  #====保存された状態から、リストアします。
  def restore_state(_state)
  end

  #===エージェントのプロパティ
  class Property

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    #====コンストラクタ
    # id:: プロパティID
    # name:: UIでの表示名
    # default_value:: プロパティの初期値
    # type:: 種類
    def initialize(id, name, default_value = nil, type = :string)
      @id = id
      @name = name
      @default = default_value
      @type = type
    end
    # プロパティID。
    # JIJI::Agent#properties=(props)で渡されるハッシュのキーになります。設定必須です。
    attr_writer :id
    # UIでの表示名。設定必須です。
    attr_writer :name
    # プロパティの初期値。
    attr_writer :default
    # 種類。:string or :numberが指定可能。指定しない場合、:stringが指定されたものとみなされます。
    attr_writer :type

    def values
      [@id, @name, @type, @default]
    end

    def to_h # nodoc
      { id: id, name: name, type: type, default: default }
    end

  end
end
