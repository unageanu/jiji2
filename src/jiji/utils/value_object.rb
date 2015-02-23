
module Jiji::Utils::ValueObject
  def ==(other)
    _eql?(other) { |a, b| a == b }
  end

  def eql?(other)
    _eql?(other) { |a, b| a.eql? b }
  end

  def hash
    hash = 0
    values.each do|v|
      hash = v.hash + 31 * hash
    end
    hash
  end

  protected

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
    return true if self.equal? other
    return false unless other.is_a?(Jiji::Utils::ValueObject)
    a = values
    b = other.values
    return false if a.length != b.length
    a.length.times do|i|
      return false unless block.call(a[i], b[i])
    end
    true
  end
end
