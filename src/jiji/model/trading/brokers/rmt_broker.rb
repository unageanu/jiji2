# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Trading
module Brokers

  class RMTBroker < AbstractBroker
    
    include Encase
    
    needs :rmt_broker_setting
    
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
    
    def order( pair_id, type, count )
      check_setting_finished
      position = securities.order(pair_id, type, count)
      @positions[position.position_id] = position
      return position
    end
    
    def commit( position_id, count=1 )
      securities.commit(position_id, count)
    end
    
    def destroy
      securities.destroy_plugin if securities
    end
  
  protected
    def retrieve_pairs
      securities ? securities.list_pairs : []
    end
    def retrieve_rates
      securities ? convert_rates(securities.list_rates) : {}
    end
  
  private
    def check_setting_finished
      raise Jiji::Errors::NotInitializedException.new unless securities
    end
    def securities
      @rmt_broker_setting.active_securities
    end
    def convert_rates(rate, timestamp=Time.now )
      rate.reduce({}){|r,p|
        r[p[0]] = convert_rate_to_tick(p[0], p[1], timestamp )
        r
      }
    end
    def convert_rate_to_tick( pair_id, rate, timestamp )
      Tick.new {|r|
        r.bid       = rate.bid
        r.ask       = rate.ask
        r.sell_swap = rate.sell_swap
        r.buy_swap  = rate.buy_swap
        r.pair_id   = pair_id
        r.timestamp = timestamp
      }
    end
  end

end
end
end
end