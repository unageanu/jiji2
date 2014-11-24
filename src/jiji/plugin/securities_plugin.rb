
require 'thread'

module JIJI
  module Plugin
    
    #
    #===証券会社アクセスプラグイン
    #
    #証券会社へのアクセスを提供するプラグインのインターフェイスを示すモジュール。
    #証券会社アクセスプラグインはこのモジュールが示すメソッドを実装する必要があります。
    #
    module SecuritiesPlugin
      
      #プラグイン識別子
      FUTURE_NAME = :securities
      
      #プラグインの識別子を返します。
      def plugin_id
      end
      
      #プラグインの表示名を返します。
      #「jiji setting」での証券会社選択時に使用します。
      def display_name
      end
      
      #「jiji setting」でユーザーに入力を要求するデータの情報を返します。
      #return:: JIJI::Plugin::Securities::Inputの配列
      def input_infos 
      end
      
      #プラグインを初期化します。プラグインの利用が開始される前に1度だけ呼び出されます。
      #引数として、ユーザーが入力したパラメータが渡されます。
      #props:: ユーザーが入力したパラメータ(JIJI::Plugin::Securities::Inputのkeyをキーとする設定値の配列)
      #logger:: ロガー
      def init_plugin( props, logger ) 
      end
      
      #プラグインを破棄します。jijiの停止時に1度だけ呼び出されます。
      def destroy_plugin
      end
      
      #利用可能な通貨ペア一覧を取得します。
      #return:: JIJI::Plugin::Securities::Pairの配列
      def list_pairs
      end
      
      #現在のレートを取得します。
      #return:: 通貨ペア名をキーとするJIJI::Plugin::Securities::Rateのハッシュ
      def list_rates
      end
      
      #成り行きで発注を行います。
      #pair:: 通貨ペア名
      #sell_or_buy:: 売(:sell)または買い(:buy)
      #count:: 取引数量
      #return:: JIJI::Plugin::Securities::Position
      def order( pair, sell_or_buy, count )
      end
      
      #建玉を決済します。
      #position_id:: 建玉ID
      #count:: 取引数量
      def commit( position_id, count )
      end
      
      #===ユーザーに入力を要求するデータの情報
      #key:: データのキー
      #description:: 入力時に表示する説明
      #secure:: UIでの入力値の表示を行うかどうか。trueにするとUI上では「*」で表示されます。
      #validator:: UIでの入力値のチェックを行うProc。引数として文字列を受け取り、
      #                 エラーがあった場合はエラーメッセージ、問題ない場合はnilを返すこと。
      #                 nilを指定すると、入力値のチェックを行わない。
      Input = Struct.new( :key, :description, :secure, :validator )
      
      #===取引可能な通貨ペア
      #name:: 通貨ペア名 例) :EURJPY
      #tade_unit:: 取引単位
      Pair = Struct.new( :name, :trade_unit )
      
      #===レート
      #bid:: bidレート
      #ask:: askレート
      #sell_swap:: 売りスワップ
      #buy_swap:: 買いスワップ
      Rate = Struct.new( :bid, :ask, :sell_swap, :buy_swap )
      
      #===建玉
      #position_id:: 建玉の識別子
      Position = Struct.new( :position_id )
    end
    
    # 証券会社アクセスプラグインのマネージャ
    class SecuritiesPluginManager
      
      def initialize
        @mutex = Mutex.new
        @selected = nil
      end
      
      #登録済みプラグインの一覧を返す。
      #return:: 登録済みプラグインの配列
      def all
        JIJI::Plugin.get( JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME )
      end
      
      #選択されたプラグインインスタンスを取得する。
      #return:: 選択されているプラグインインスタンス
      def selected
        return @mutex.synchronize {
          unless @selected
            id = conf.get([:securities, :type], "illegal" ).to_sym
            @selected = all.find {|plugin|
              id == plugin.plugin_id.to_sym
            }
            raise FatalError.new( JIJI::ERROR_NOT_FOUND, "Securities plugin isnot found. plugin_id=#{id}" ) unless @selected
            @selected.init_plugin( conf.get( [:securities], {} ), @server_logger )
          end
          @selected
        }
      end
      
      #プラグインを破棄する。
      def close
        @mutex.synchronize {
          @selected.destroy_plugin if @selected
        }
      end
      attr :server_logger, true
      attr :conf, true
    end
    
  end
end
