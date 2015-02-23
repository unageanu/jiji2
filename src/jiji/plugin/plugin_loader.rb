require 'set'
require 'encase'
require 'singleton'

module JIJI::Plugin
  # プラグインを登録する。
  # future:: 機能の識別子
  # instance:: 機能を提供するプラグインインスタンス
  def self.register(future, instance)
    Registry.instance.register(future, instance)
  end

  # プラグインを取得する。
  # future:: 機能の識別子
  # return:: 機能を提供するプラグインの配列
  def self.get(future)
    Registry.instance.get(future)
  end

  class Registry
    include Singleton

    def initialize
      @registry = {}
    end

    def register(future, instance)
      if @registry.key? future
        @registry[future] << instance
      else
        @registry[future] = [instance]
      end
    end

    def get(future)
      @registry.key?(future) ? @registry[future] : []
    end
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
    ($LOAD_PATH + Gem.path).each do|dir|
      Dir.glob("#{dir}/**/jiji_plugin.rb").each do|plugin|
        load_plugin(File.expand_path plugin)
      end
    end
  end

  def load_plugin(plugin)
    return unless File.exist? plugin
    return if @loaded.include?(plugin)
    begin
      Kernel.require plugin
      @logger.info("plugin loaded. plugin_path=#{plugin}")
    rescue Exception => e
      handle_error(plugin, e)
    ensure
      @loaded << plugin
    end
  end

  def handle_error(plugin, error)
    @logger.error("plugin load failed. plugin_path=#{plugin}")
    @logger.error(error)
  end
end
