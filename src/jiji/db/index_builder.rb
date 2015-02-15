# coding: utf-8

require 'mongoid'
require 'jiji/configurations/mongoid_configuration'

class Jiji::Db::IndexBuilder

  def create_indexes
    Mongoid.models.each {|m|
      next if m.index_specifications.empty?
      next if m.embedded? && !m.cyclic?
      m.create_indexes
    }
  end

end