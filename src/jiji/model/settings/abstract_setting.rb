# coding: utf-8

require 'bcrypt'
require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Settings

  class AbstractSetting
    
    include Mongoid::Document
    
    store_in collection: "settings"
    
    field :category, type: Symbol, default: nil
        
    def initialize
      super
      @setting_changed_listener = []
    end
    def on_setting_changed( &proc )
      @setting_changed_listener << proc
    end
  
  protected
  
    def self.find(category)
      AbstractSetting.find_by( :category => category )
    end
    
    def fire_setting_changed_event( key, event )
      @setting_changed_listener.each {|l|
        l.call( key, event )
      }
    end
    
  end

end
end
end