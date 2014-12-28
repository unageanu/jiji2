# coding: utf-8

require 'encase'

require 'jiji/composing/container_factory'

module Jiji
module Model
  
  class Application
    
    include Encase
    
    needs :plugin_loader
    needs :rmt_broker_setting
    needs :rmt_process
    
    def setup
      @plugin_loader.load
      @rmt_broker_setting.setup
      @rmt_process.start
    end
    
    def tear_down
      @rmt_process.stop
    end
    
  end

end
end