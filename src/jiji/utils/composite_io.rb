
module Jiji::Utils
  class CompositeIO
    def initialize(*targets)
       @targets = targets
    end

    def write(*args)
      @targets.each {|t| t.write(*args)}
    end

    def close
      @targets.each {|t| t.close unless t.equals(STDOUT) }
    end
  end
end
