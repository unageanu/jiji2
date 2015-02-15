require 'set'
require 'encase'

module JIJI::Plugin
    
  @@registry = {}
  
  #プラグインを登録する。
  #future:: 機能の識別子
  #instance:: 機能を提供するプラグインインスタンス
  def self.register( future, instance )
    if @@registry.key? future 
      @@registry[future] << instance
    else
      @@registry[future] = [instance]
    end
  end
  
  #プラグインを取得する。
  #future:: 機能の識別子
  #return:: 機能を提供するプラグインの配列
  def self.get( future )
    @@registry.key?(future) ? @@registry[future] : []
  end

end

# プラグインローダー
class Jiji::Plugin::Loader
  
  include Encase
  
  needs :logger
  
  def initialize
    @loaded = Set.new
  end
  # プラグインをロードする。
  def load
    ($: + Gem.path).each {|dir|
      Dir.glob("#{dir}/**/jiji_plugin.rb").each {|plugin|
        load_plugin( File.expand_path plugin )
      }
    }
  end
  
  def load_plugin( plugin )
    return unless File.exist? plugin
    return if @loaded.include?( plugin )
    begin 
      Kernel.require plugin
      @logger.info( "plugin loaded. plugin_path=#{plugin}" )
    rescue Exception
      handle_error(plugin, $!)
    ensure
      @loaded << plugin
    end
  end
  
  def handle_error(plugin, error)
    @logger.error( "plugin load failed. plugin_path=#{plugin}" ) 
    @logger.error(error)  
  end
  
end

