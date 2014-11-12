# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Dao

  class Setting
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "settings"
    
    field :category
    field :values, type: Hash
  
  end

end
end
end
