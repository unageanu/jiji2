# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'


module Jiji::Model::Graph
class GraphData

  include Mongoid::Document
  
  
  store_in collection: "graph-data"
  
  field :id,        type: String
  field :values,    type: Array
  field :timestamp, type: Time
  
  index({ :id =>1, :timestamp=> 1 }, { name: "graph-data_id_timestamp_index" })
  
  def self.create( id, values, time=Time.now )
    Data.new {|d|
        d.id        = id
        d.values    = values
        d.timestamp = time
    }
  end
  
  def [](key) 
    values[key]
  end
  def []=(key, value) 
    values[key] = value
  end
  
end
end