# coding: utf-8
require 'time'

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
