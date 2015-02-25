# coding: utf-8
require 'time'

class Time

  def to_json(*a)
    iso8601.to_json(*a)
  end

end
