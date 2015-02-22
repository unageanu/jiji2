# coding: utf-8
require 'time'

class Time
  def to_msgpack(*a)
    (to_i * 1000).to_msgpack(*a)
  end
end
