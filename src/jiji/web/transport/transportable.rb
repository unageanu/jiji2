module Jiji
module Web
module Transport
  
  module Transportable
    
    def to_h
      super
    end
    
    def to_json(*a)
      to_h.to_json(*a)
    end
    
    def to_msgpack(*a)
      to_h.to_msgpack(*a)
    end
    
  end

end
end
end