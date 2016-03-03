
module Jiji::Utils::ValueObject
  def ==(other)
    _eql?(other) { |a, b| a == b }
  end

  def eql?(other)
    _eql?(other) { |a, b| a.eql? b }
  end

  def hash
    hash = 0
    values.each do |v|
      hash = v.hash + 31 * hash
    end
    hash
  end

  def to_h
    collect_properties
  end

  def from_h(hash)
    hash.each do |k, v|
      key = '@' + k.to_s
      instance_variable_set(key, v) if instance_variable_defined?(key)
    end
  end

  protected

  def collect_properties(keys = instance_variables.map { |n| n[1..-1] })
    keys.each_with_object({}) do |name, obj|
      obj[name.to_sym] = instance_variable_get('@' + name.to_s)
    end
  end

  def values
    values = []
    values << self.class
    instance_variables.each do |name|
      values << instance_variable_get(name)
    end
    values
  end

  def _eql?(other, &block)
    return false if other.nil?
    return true if equal? other
    return false unless other.is_a?(Jiji::Utils::ValueObject)
    a = values
    b = other.values
    return false if a.length != b.length
    a.length.times do |i|
      return false unless yield(a[i], b[i])
    end
    true
  end
end
