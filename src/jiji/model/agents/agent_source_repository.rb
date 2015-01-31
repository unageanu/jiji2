# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Agents 

  class AgentSourceRepository

    def get_all
      AgentSource.all.map {|a| a.evaluate; a }
    end
    
    def get_by_type( type )
      AgentSource.where({ 
        :type=>type 
      }).order_by(:name.asc).without(:body, :error)
    end
    
    def get_by_id( id )
      source = AgentSource.find(id)
      source.evaluate
      source
    end
    
  end

end
end
end