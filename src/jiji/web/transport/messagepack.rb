# frozen_string_literal: true

require 'time'
require 'mongoid'

class Time

  def to_msgpack(*a)
    iso8601.to_msgpack(*a)
  end

end

class Struct

  def to_msgpack(*a)
    to_h.to_msgpack(*a)
  end

end

class BigDecimal

  def to_msgpack(*a)
    to_f.to_msgpack(*a)
  end

end

class BSON::ObjectId

  def to_msgpack(*a)
    to_s.to_msgpack(*a)
  end

end
