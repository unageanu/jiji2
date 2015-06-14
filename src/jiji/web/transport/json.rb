# coding: utf-8
require 'time'
require 'mongoid'

class Time

  def to_json(*a)
    iso8601.to_json(*a)
  end

end

class Struct

  def to_json(*a)
    to_h.to_json(*a)
  end

end

class BigDecimal

  def to_json(*a)
    to_f.to_json(*a)
  end

end

class BSON::ObjectId

  def to_json(*a)
    to_s.to_json(*a)
  end

end
