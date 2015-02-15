# coding: utf-8

require 'encase'

require 'jiji/composing/container_factory'

module Jiji::Model
class Application
  
  include Encase
  
  needs :plugin_loader
  needs :rmt_broker_setting
  needs :rmt_process
  needs :back_test_repository
  needs :index_builder
  
  def setup
    @index_builder.create_indexes
    
    @plugin_loader.load
    @rmt_broker_setting.setup
    @rmt_process.start
  end
  
  def tear_down
    @rmt_process.stop.value
    @back_test_repository.stop
  end
  
end
end