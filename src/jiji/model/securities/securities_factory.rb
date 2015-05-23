# coding: utf-8

require 'thread'

module Jiji::Model::Securities

  class SecuritiesFactory

    include Jiji::Errors

    def initialize
      @available_securities = {}
      @classes = {}

      register_securities( :OANDA_JAPAN, "OANDA Japan",
        OandaSecurities.configuration_definition, OandaSecurities )
      register_securities( :OANDA_JAPAN_DEMO, "OANDA Japan DEMO",
        OandaSecurities.configuration_definition, OandaDemoSecurities )
    end

    def available_securities
      @available_securities.values
    end

    def get( id )
      @available_securities[id] || not_found("securities", id:id)
    end

    def create( id, props={} )
      if !@available_securities.include?(id) || !@classes.include?(id)
        not_found("securities", id:id)
      end
      return @classes[id].new( props )
    end

    def register_securities( id,
      display_name, configuration_definition, clazz )
      @available_securities[id] = {
        id: id,
        display_name: display_name,
        configuration_definition: configuration_definition || {}
      }
      @classes[id] = clazz
    end

  end

end
