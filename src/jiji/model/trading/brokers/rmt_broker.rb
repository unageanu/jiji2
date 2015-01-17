# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/brokers/abstract_broker'

module Jiji
module Model
module Trading
module Brokers

  class RMTBroker < AbstractBroker
    
    include Encase
    
    needs :rmt_broker_setting
    needs :time_source
    
    def initialize
      super()
      @back_test_id = nil
    end
    
    def has_next
      true
    end
    
    def positions
      check_setting_finished
      super
    end
    
    def buy( pair_id, count=1 )
      order(pair_id, :buy, count )
    end
    
    def sell( pair_id, count=1 )
      order(pair_id, :sell, count )
    end
    
    def close( position_id )
    end
    
    def destroy
      securities.destroy_plugin if securities
    end
  
  private
    def retrieve_pairs
      securities ? securities.list_pairs : []
    end
    def retrieve_rates
      securities ? convert_rates(securities.list_rates, time_source.now) 
                 : Jiji::Model::Trading::NilTick.new
    end
    
    def order( pair_id, type, count )
      check_setting_finished
      position = securities.order(pair_id, type, count)
      @positions[position.position_id] = position
      return position
    end
  
    def check_setting_finished
      raise Jiji::Errors::NotInitializedException.new unless securities
    end
    def securities
      @rmt_broker_setting.active_securities
    end
    def convert_rates(rate, timestamp )
      values = rate.reduce({}){|r,p|
        r[p[0]] = convert_rate_to_tick(p[1])
        r
      }
      Tick.create(values, timestamp)
    end
    def convert_rate_to_tick( r )
      Tick::Value.new(r.bid, r.ask, r.buy_swap, r.sell_swap) 
    end
  end

end
end
end
end