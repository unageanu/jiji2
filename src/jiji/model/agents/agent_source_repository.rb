# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Agents 

  class AgentSourceRepository

    def get_all
      AgentSource.all.without(:body, :error)
    end
    
    def get_by_type( type )
      AgentSource \
        .find_by({ :type=>type }) \
        .order_by( {:name=>1} ) \
        .without(:body, :error)
    end
    
    def get_by_id_with_body( id )
      source = AgentSource.find(id)
      source.evaluate
      source
    end
    
  end

end
end
end