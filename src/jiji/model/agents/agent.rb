# frozen_string_literal: true

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Agents::Agent
  # 設定可能なプロパティの一覧を返します。
  #
  # * 必要に応じて実装してください。
  #
  # 戻り値:: Jiji::Model::Agents::Agent::Property の配列
  def self.property_infos
    []
  end

  # エージェントの説明を返します。
  #
  # * 必要に応じて実装してください。
  def self.description
    ''
  end

  # プロパティ
  attr_reader :properties

  # プロパティを設定します。
  #
  # properties:: プロパティIDをキー、プロパティ値を値とするハッシュ
  def properties=(properties)
    @properties = properties
    properties.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  # エージェント名
  attr_accessor :agent_name
  # アイコンID
  attr_accessor :icon_id
  # 取引の実行など、証券会社へのアクセスを提供するコンポーネント
  attr_accessor :broker
  # グラフの描画で使用するコンポーネント
  attr_accessor :graph_factory
  # Push通知、メール送信機能を提供するコンポーネント
  attr_accessor :notifier
  # ロガー
  attr_accessor :logger

  # エージェントの登録後に1度だけ呼び出される関数です。
  #
  # * コンストラクタと違い、このメソッド内ではbrokerやgraph_factory,logger
  #   等が使用可能です。
  def post_create; end

  # レート情報が通知されるメソッドです。
  #
  # * エージェントが動作している間順次呼び出されます。
  # * このメソッドをオーバーライドして、シグナルの計算や取り引きを行うロジック
  #   を実装します
  #
  # tick:: Jiji::Model::Trading::Tick
  def next_tick(tick); end

  # アクションを実行します。
  #
  # action:: アクションの識別子
  # 戻り値:: 応答メッセージ。画面からアクションを実行した時のレスポンスとして
  #       表示されます。
  def execute_action(action)
    'OK'
  end

  # エージェントの状態を返します。
  #
  # * システム停止時に呼び出されます。返された値は、次回システムを起動したときに、
  #   restore_state の引数で渡されます。
  # * 状態はMongoid#Hash として永続化されます。#Hashに格納できない型を返却すると
  #   永続化に失敗しますのでご注意ください。 文字列や数値型であれば、問題ありません。
  #
  # 戻り値:: 状態。Mongoid#Hash として永続化されます。
  def state
    {}
  end

  # 保存された状態データから、状態を復元します。
  #
  # * 必要に応じてオーバーライドしてください。
  #
  # state:: 状態データ
  def restore_state(state); end

  # エージェントのプロパティ
  class Property

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # コンストラクタ
    #
    # id:: プロパティID
    # name:: UIでの表示名
    # default_value:: プロパティの初期値
    # type:: 種類
    def initialize(id, name, default_value = nil)
      @id = id
      @name = name
      @default = default_value
    end

    # プロパティID。
    # * Jiji::Model::Agents::Agent#properties=(props)で渡されるハッシュのキー
    #   になります。設定必須です。
    attr_accessor :id
    # UIでの表示名。設定必須です。
    attr_accessor :name
    # プロパティの初期値。
    attr_accessor :default

    def values
      [@id, @name, @type, @default]
    end

    def to_h # nodoc
      { id: id, name: name, default: default }
    end

  end
end
