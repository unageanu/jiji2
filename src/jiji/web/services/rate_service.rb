# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji
module Web

  class RateService < Jiji::Web::AuthenticationRequiredService
    
    delete "/" do
      range = get_range
      Jiji::Model::Trading::Tick.delete( range[:start], range[:end] )
      Jiji::Model::Trading::Swap.delete( range[:start], range[:end] )
      no_content
    end
    
    get "/range" do
      ok( Jiji::Model::Trading::Tick.range )
    end
    
    get "/pairs" do
      ok( Jiji::Model::Trading::Pairs.instance.all )
    end
    
    get "/:pair_name/:interval" do
      range = get_range
      pair_name = params["pair_name"].to_sym
      interval  = params["interval"].to_sym
      ok( fetcher.fetch(pair_name, 
        range[:start], range[:end], interval) )
    end
    
    def fetcher
      lookup(:rate_fetcher)
    end
    
    def get_range
      return {
        :start => get_time_from_query_parm("start"),
        :end   => get_time_from_query_parm("end")
      }
    end
    
  end

end
end