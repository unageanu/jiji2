
module Jiji::Utils::ValueObject
    
  def ==(other)
    _eql?(other) { |a,b| a == b }
  end
  def ===(other)
    _eql?(other) { |a,b| a === b }
  end
  def eql?(other)
    _eql?(other) { |a,b| a.eql? b }
  end
  def hash
    hash = 0
    values.each {|v|
      hash = v.hash + 31 * hash
    }
    return hash
  end
protected
  def values
    values = []
    values << self.class
    instance_variables.each { |name|
      values << instance_variable_get(name) 
    }
    return values
  end
  def _eql?(other, &block)
    return false if other == nil
    return true if self.equal? other
    return false unless other.kind_of?(Jiji::Utils::ValueObject)
    a = values
    b = other.values
    return false if a.length != b.length
    a.length.times{|i|
      return false unless block.call( a[i], b[i] )
    }
    return true
  end

end
