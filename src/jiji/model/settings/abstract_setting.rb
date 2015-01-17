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
    
    index({ :category => 1 }, { unique:true, name: "settings_category_index" })
    
    attr_readonly :category
    
    after_initialize :init

    def initialize
      super
      init
    end
    def on_setting_changed( &proc )
      @setting_changed_listener << proc
    end
  
  private
    def self.find(category)
      AbstractSetting.find_by( :category => category )
    end
    
    def fire_setting_changed_event( key, event )
      @setting_changed_listener.each {|l|
        l.call( key, event )
      }
    end
    
    def init
      @setting_changed_listener = []
    end
  
  end

end
end
end