# coding: utf-8

require 'jiji/plugin/securities_plugin'

module Jiji
module Test 
module Mock
  
  class MockSecuritiesPlugin
    
    include JIJI::Plugin::SecuritiesPlugin
    
    attr :props
    attr_accessor :seed
    
    def initialize(id)
      @serial= 0
      @id    = id
      @seed  = 0
    end
    
    def plugin_id
      @id
    end
    
    def display_name
      "mock plugin"
    end
    
    def input_infos
      return [
        Input.new( 'a', 'aaa', true,  nil ),
        Input.new( 'b', 'bbb', false, nil ),
        Input.new( 'c', 'ccc', true,  proc {|v| v == "c" ? "error" : nil  } )
      ]
    end
    
    def init_plugin( props, logger ) 
      @props = props
    end
    
    def destroy_plugin
    end
    
    def list_pairs
      raise RuntimeError.new, "test" if @seed == :error
      return [
        Pair.new(:EURJPY, 10000),
        Pair.new(:EURUSD, 10000),
        Pair.new(:USDJPY, 10000)
      ]
    end
    
    def list_rates
      raise RuntimeError.new, "test" if @seed == :error
      return {
        :EURJPY => Rate.new( 145.00 + @seed, 145.003 + @seed, 10, -20),
        :EURUSD => Rate.new( 1.2233 + @seed,  1.2234 + @seed, 11, -16),
        :USDJPY => Rate.new(119.435 + @seed, 119.443 + @seed, -8,   2)
      }
    end
    
    def order( pair, sell_or_buy, count )
      @serial+=1
      return Position.new(@serial)
    end

    def commit( position_id, count )
    end
    
    def self.instance 
       Jiji::Model::Settings::RMTBrokerSetting.available_securities.find {|p| p.plugin_id == :mock}
    end
    
  end
  
end
end
end


JIJI::Plugin.register( 
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME, 
  Jiji::Test::Mock::MockSecuritiesPlugin.new(:mock) )
JIJI::Plugin.register( 
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME, 
  Jiji::Test::Mock::MockSecuritiesPlugin.new(:mock2) )
