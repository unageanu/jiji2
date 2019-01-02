# frozen_string_literal: true

require 'time'
require 'mongoid'

class NilClass

  def to_csv_value
    ''
  end

end

class Hash

  def to_csv_value
    to_json.to_csv_value
  end

end

class Numeric

  def to_csv_value
    to_json.to_csv_value
  end

end

class Array

  def to_csv_value
    to_json.to_csv_value
  end

end

class String

  def to_csv_value
    include?(',') ? "\"#{gsub(/\"/, '""')}\"" : self
  end

end

class Symbol

  def to_csv_value
    to_s.to_csv_value
  end

end

class Time

  def to_csv_value
    iso8601.to_csv_value
  end

end

class Struct

  def to_csv_value
    to_h.to_json.to_csv_value
  end

end

class BigDecimal

  def to_csv_value
    to_f.to_json.to_csv_value
  end

end

class BSON::ObjectId

  def to_csv_value
    to_s.to_csv_value
  end

end
